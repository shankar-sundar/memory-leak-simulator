package com.redhat;

import java.lang.management.ManagementFactory;
import java.lang.management.MemoryUsage;
import java.text.DecimalFormat;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType; 

@Path("/getMemoryDetails")
public class MemoryDetailResource {

    public String floatForm (double d)
    {
       return new DecimalFormat("#.##").format(d);
    }

    public String bytesToHuman (long size)
    {
        long Kb = 1  * 1024;
        long Mb = Kb * 1024;
        long Gb = Mb * 1024;
        long Tb = Gb * 1024;
        long Pb = Tb * 1024;
        long Eb = Pb * 1024;

        if (size <  Kb)                 return floatForm(        size     ) + " byte";
        if (size >= Kb && size < Mb)    return floatForm((double)size / Kb) + " Kb";
        if (size >= Mb && size < Gb)    return floatForm((double)size / Mb) + " Mb";
        if (size >= Gb && size < Tb)    return floatForm((double)size / Gb) + " Gb";
        if (size >= Tb && size < Pb)    return floatForm((double)size / Tb) + " Tb";
        if (size >= Pb && size < Eb)    return floatForm((double)size / Pb) + " Pb";
        if (size >= Eb)                 return floatForm((double)size / Eb) + " Eb";

        return "???";
    }

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String getMemoryDetails(){
        MemoryUsage memoryUsage = ManagementFactory.getMemoryMXBean().getHeapMemoryUsage() ;
        return String.format("Min [%s], Current Usage [%s], Max [%s]"
                                ,bytesToHuman(memoryUsage.getInit())
                                ,bytesToHuman(memoryUsage.getUsed())
                                ,bytesToHuman(memoryUsage.getMax()));
    }
}
