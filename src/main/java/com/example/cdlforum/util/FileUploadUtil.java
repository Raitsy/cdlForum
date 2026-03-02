package com.example.cdlforum.util;

import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

public class FileUploadUtil {

    private static final long MAX_SIZE = 5 * 1024 * 1024; // 5 MB

    /**
     * Saves a multipart Part to {webappRoot}/uploads/{subDir}/ and returns the
     * context-relative URL path (e.g. "/uploads/channels/uuid.png").
     *
     * @param part       the Part from the multipart request
     * @param subDir     sub-directory name (e.g. "channels")
     * @param webappRoot absolute filesystem path to the deployed webapp root
     * @return relative URL path, or null if the part is empty / too large
     */
    public static String save(Part part, String subDir, String webappRoot) throws IOException {
        if (part == null || part.getSize() == 0)
            return null;
        if (part.getSize() > MAX_SIZE)
            return null;

        String original = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0)
            extension = original.substring(dot).toLowerCase();

        // Whitelist safe image extensions
        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp|svg)"))
            return null;

        String fileName = UUID.randomUUID() + extension;
        String dirPath = webappRoot + File.separator + "uploads" + File.separator + subDir;

        Files.createDirectories(Paths.get(dirPath));

        try (InputStream in = part.getInputStream()) {
            Files.copy(in, Paths.get(dirPath, fileName), StandardCopyOption.REPLACE_EXISTING);
        }

        return "/uploads/" + subDir + "/" + fileName;
    }
}
