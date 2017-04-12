package com.ze.bean;

/**
 * Created by moe on 4/11/2017.
 */
public class GasPrice {
    private long id;
    private double price;
    private String station;
    private String area;
    private String lastUpdated;

    public GasPrice(long id, double price, String station, String area, String lastUpdated) {
        this.id = id;
        this.price = price;
        this.station = station;
        this.area = area;
        this.lastUpdated = lastUpdated;
    }

    public long getId() { return id;
    }
    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public void setStation(String station) {
        this.station = station;
    }

    public String getStation() {
        return station;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}
