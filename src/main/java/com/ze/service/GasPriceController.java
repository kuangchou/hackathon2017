package com.ze.service;


import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

import com.ze.bean.GasPrice;
import com.ze.processor.DataProcessorException;
import com.ze.processor.GasPriceProcessor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GasPriceController {

    private static final String template = "ZIP Code, %s!";

    @RequestMapping("/gasprice")
    public List<GasPrice> gasprice(@RequestParam(value = "zipCode", defaultValue = "V7C 4R9") String zipCode) {
        List<GasPrice> aList = null;
        GasPriceProcessor hw = new GasPriceProcessor();
        try {
            aList = hw.process(zipCode);
        }
        catch (DataProcessorException e) {
            e.printStackTrace();
        }

        return aList;
    }
}
