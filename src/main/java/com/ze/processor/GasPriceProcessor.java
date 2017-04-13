package com.ze.processor;

import java.io.Closeable;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.xpath.XPathAPI;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.tidy.Configuration;
import org.w3c.tidy.Tidy;

import com.ze.bean.GasPrice;

public class GasPriceProcessor {

  private final AtomicLong counter = new AtomicLong();

  private static final Pattern LAST_UPDATE_PATTERN =
          Pattern.compile("(?i).*?(\\d+\\s+(?:minute|hour|day)s?\\s+ago)");

  public List<GasPrice> process(final String zipCode) throws DataProcessorException {
    final Map<String, String> record = new HashMap<String, String>();
    final List<GasPrice> recordList = new ArrayList<>();
    List<String> headerList = null;
    InputStream inputStream = null;

    try {
      try {
        final String sourecUrl =
                String.format("http://www.bcgasprices.com/GasPriceSearch.aspx?fuel=A&qsrch=%s",
                        zipCode.replaceAll(" ", "%20"));
        final URI uri = new URI(sourecUrl);
        final URL url = uri.toURL(); // get URL from your uri object
        inputStream = url.openStream();
      }
      catch (final MalformedURLException e) {
        e.printStackTrace();
      }
      catch (final URISyntaxException e) {
        e.printStackTrace();
      }
      catch (final IOException e) {
        e.printStackTrace();
      }

      final Node root = getRootNode(inputStream, Configuration.UTF8, true, true, true, true, false, true, true);
      final Node table = getXPath(root, "//table[contains(@class, 'p_v2')]").item(0);
      for (Node rowNode = table.getFirstChild(); rowNode != null; rowNode = rowNode.getNextSibling()) {
        if ("thead".equalsIgnoreCase(rowNode.getNodeName())) {
          headerList = getTableRowAsList(rowNode.getFirstChild());
          continue;
        }
        if ("tbody".equalsIgnoreCase(rowNode.getNodeName())) {
          rowNode = rowNode.getFirstChild();
        }

        final List<String> values = getTableRowAsList(rowNode);
        record.clear();
        for (int i = 0; i < headerList.size(); i++) {
          final String value = i < headerList.size() ? values.get(i).trim() : null;
          if (value != null && !value.isEmpty()) {
            record.put(headerList.get(i), value);
          }
        }
        System.out.println("==============================");
        for (Map.Entry<String, String> ent : record.entrySet()) {
          System.out.println(ent.getKey() + " -->> " + ent.getValue());
        }
        GasPrice gasPrice = getGasPrice(record);
        if (gasPrice != null) {
          recordList.add(gasPrice);
        }
      }
    }
    finally {
      close(inputStream);
    }
    recordList.stream().sorted((e1, e2) -> Double.compare(e1.getPrice(), e2.getPrice()));
    return recordList.subList(0, 10);
  }

  private GasPrice getGasPrice(final Map<String, String> record) {
    GasPrice gasPrice = null;
    double price = getPrice(record.get("Price"));
    if (price != -1) {
      gasPrice = new GasPrice(
              counter.incrementAndGet(),
              getPrice(record.get("Price")),
              record.get("Station"),
              record.get("Area"),
              getLastUpdated(record.get("Thanks")));
    }
    return gasPrice;
  }

  private String getLastUpdated(String thanks) {
    String lastUpdated = null;
    final Matcher matcher = LAST_UPDATE_PATTERN.matcher(thanks);
    if (matcher.matches()) {
      lastUpdated = matcher.group(1).trim();
    }
    return lastUpdated;
  }

  private double getPrice(String rawPrice) {
    double price = -1;
    try {
      price = new BigDecimal(rawPrice.replaceAll("(?i)update", "").trim()).doubleValue();
    }
    catch (final NumberFormatException e) {
      System.out.println("Unable to parse Gas Price from: " + rawPrice);
    }

    return price;
  }

  private List<String> getTableRowAsList(final Node rowNode) {
    final List<String> rowList = new ArrayList<String>();
    final NodeList tableRow = rowNode.getChildNodes();
    for (int j = 0; j < tableRow.getLength(); j++) {
      final Node valueNode = tableRow.item(j);
      final String valueTxt = getTextFromNode(valueNode);
      for (int i = 0; i < getColSpan(valueNode); i++) {
        rowList.add(valueTxt);
      }
    }
    return rowList;
  }

  private int getColSpan(final Node cell) {
    int result = 1;
    final String colSpan = getXPathResult(cell, "./@colspan");

    if (colSpan != null && !colSpan.isEmpty()) {
      result = Integer.parseInt(colSpan);
    }

    return result;
  }

  private String getTextFromNode(final Node node) {
    final StringBuilder stringBuilder = new StringBuilder();
    for (Node n = node.getFirstChild(); n != null; n = n.getNextSibling()) {
      if (n.getNodeType() == Node.TEXT_NODE) {
        stringBuilder.append(n.getNodeValue());
      }
      else {
        stringBuilder.append(" ").append(getTextFromNode(n));
      }
    }
    return stringBuilder.toString().trim();
  }

  private void close(final Object closeable) {
    if (closeable != null) {
      try {
        if (closeable instanceof Closeable) {
          ((Closeable) closeable).close();
        }
      }
      catch (final IOException e) {
        System.out.println("Error closing: " + e.getMessage());
      }
    }
  }

  public static Node getRootNode(InputStream is, int charEncoding, boolean makeClean, boolean xHTML, boolean xmlPi,
      boolean xmlPIs, boolean showWarnings, boolean onlyErrors, boolean quiet) {
    if (null == is) throw new IllegalArgumentException("InputStream parameter is null");

    Node rootDocumentNode = null;

    // transform to xml using Tidy...
    try {
      Tidy tidy = new Tidy();
      tidy.setMakeClean(makeClean);
      tidy.setXHTML(xHTML);
      tidy.setXmlPi(xmlPi);
      tidy.setXmlPIs(xmlPIs);
      tidy.setShowWarnings(showWarnings);
      tidy.setOnlyErrors(onlyErrors);
      tidy.setQuiet(quiet);
      tidy.setCharEncoding(charEncoding);

      Document document = tidy.parseDOM(is, null);
      rootDocumentNode = document.getDocumentElement();
    }
    catch (Exception e) {
      System.out.println(e.getMessage());
    }

    return rootDocumentNode;
  }

  public static NodeList getXPath(Node fromNode, String xPathQuery) throws DataProcessorException {
    if (null == fromNode) throw new IllegalArgumentException("Node parameter is null");
    if (null == xPathQuery) throw new IllegalArgumentException("XPath parameter is null");

    NodeList resultNodeList = null;

    try {
      resultNodeList = XPathAPI.selectNodeList(fromNode, xPathQuery);
    }
    catch (Exception e) {
      System.out.println("Cannot query the source document: " + e.getMessage());
    }

    return resultNodeList;
  }

  public static String[] getXPathResults(Node fromNode, String xPathQuery) {
    if (null == fromNode) throw new IllegalArgumentException("Node parameter is null");
    if (null == xPathQuery) throw new IllegalArgumentException("XPath parameter is null");

    String results[] = null;

    try {
      NodeList resultNodeList = XPathAPI.selectNodeList(fromNode, xPathQuery);
      if (resultNodeList == null) return null;
      if (resultNodeList.getLength() == 0) return null;

      results = new String[resultNodeList.getLength()];
      for (int i = 0; i < resultNodeList.getLength(); i++) {
        results[i] = resultNodeList.item(i).getNodeValue();
      }
    }
    catch (Exception e) {
      System.out.println("Cannot query the source document: " + e.getMessage());
    }

    return results;
  }

  public static String getXPathResult(Node fromNode, String xPathQuery) {
    if (null == fromNode) throw new IllegalArgumentException("Node parameter is null");
    if (null == xPathQuery) throw new IllegalArgumentException("XPath parameter is null");

    String result = null;

    String results[] = getXPathResults(fromNode, xPathQuery);
    if (results != null && results.length > 0) {
      result = results[0];
    }

    return result;
  }


  public static void main (String[] args)  { 
    GasPriceProcessor hw = new GasPriceProcessor();
    try {
      hw.process("V7C 4R9");
    }
    catch (DataProcessorException e) {
      e.printStackTrace();
    }
  }
}
