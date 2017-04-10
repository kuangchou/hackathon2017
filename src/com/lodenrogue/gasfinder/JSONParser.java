package com.lodenrogue.gasfinder;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

final class JSONParser {

	private JSONParser() {

	}

	public static String makeHttpRequest(String url, Method method, List<NameValuePair> params) {
		InputStream is = null;
		CloseableHttpClient httpClient = HttpClients.createDefault();
		CloseableHttpResponse httpResponse = null;

		/* Make http request */
		try {

			if (method == Method.POST) {
				HttpPost httpPost = new HttpPost(url);
				httpPost.setEntity(new UrlEncodedFormEntity(params));

				httpResponse = httpClient.execute(httpPost);
				HttpEntity httpEntity = httpResponse.getEntity();
				is = httpEntity.getContent();
			}
			else if (method == Method.GET) {
				String paramString = URLEncodedUtils.format(params, "utf-8");
				url += "?" + paramString;
				HttpGet httpGet = new HttpGet(url);

				httpResponse = httpClient.execute(httpGet);
				HttpEntity httpEntity = httpResponse.getEntity();
				is = httpEntity.getContent();
			}
			else if (method == Method.GET_PLAIN) {
				String paramString = URLEncodedUtils.format(params, "utf-8");

				/* Remove usual '=' from get paramString */
				paramString = paramString.substring(1);
				url += paramString;

				HttpGet httpGet = new HttpGet(url);
				httpResponse = httpClient.execute(httpGet);
				HttpEntity httpEntity = httpResponse.getEntity();
				is = httpEntity.getContent();
			}

		}
		catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		catch (IllegalStateException e) {
			e.printStackTrace();
		}
		catch (IOException e) {
			e.printStackTrace();
		}

		String reply = "";
		reply = getReply(is, reply);
		closeResources(httpClient, httpResponse);

		return reply;
	}

	private static void closeResources(CloseableHttpClient httpClient, CloseableHttpResponse httpResponse) {
		try {
			httpClient.close();
			if (httpResponse != null) {
				httpResponse.close();
			}
		}
		catch (IOException e1) {
			e1.printStackTrace();
		}
	}

	private static String getReply(InputStream is, String reply) {
		if (is != null) {
			try {
				BufferedReader reader = new BufferedReader(new InputStreamReader(is));
				String line = null;

				while ((line = reader.readLine()) != null) {
					reply += line + "\n";
				}
				is.close();
				reader.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		else {
			reply = "InputStream null";
		}
		return reply;
	}
}
