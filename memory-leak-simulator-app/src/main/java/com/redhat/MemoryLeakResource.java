package com.redhat;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/startMemoryLeak")
public class MemoryLeakResource {

    public static List<String> memoryHogger = new ArrayList<>();

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String consumeMemory(){
        int memoryAdder = 50;
        memoryHogger.add(new String(ByteBuffer.allocate(1024*1024*memoryAdder).array()));        
        return "Adding "+(memoryAdder*2)+"MB to heap !!!";
    }
}
