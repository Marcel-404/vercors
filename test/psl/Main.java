package test.psl;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Main {
    public static void main(String[] args) throws Exception {
        String expressions = Files.readString(Paths.get("test/psl/expressions.psl"));

        FileWriter writer = new FileWriter("test/psl/output.pvl");
        writer.write("Generated Output");
        writer.close();

    }
}