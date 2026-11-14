package com.pedidos.pedidos_api;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = "spring.datasource.url=jdbc:h2:mem:jsoncontract")
class JsonContractTests {
    @LocalServerPort
    int port;
    private final HttpClient client = HttpClient.newHttpClient();

    @Test
    void acceptsJsonProduct() throws Exception {
        var response = send("POST", "/api/productos", "application/json",
            "{\"nombre\":\"C06-contract\",\"precio\":12.5}");
        assertEquals(200, response.statusCode());
        assertTrue(response.body().contains("C06-contract"));
    }

    @Test
    void rejectsXmlOnEveryBodyRoute() throws Exception {
        String xml = "<!DOCTYPE producto [<!ENTITY xxe SYSTEM 'file:///c06-fixture'>]>"
            + "<producto><nombre>&xxe;</nombre></producto>";
        for (String resource : new String[]{"productos", "pedidos"}) {
            for (String type : new String[]{"application/xml", "text/xml", "application/problem+xml"}) {
                assertEquals(415, send("POST", "/api/" + resource, type, xml).statusCode(), resource + type);
                assertEquals(415, send("PUT", "/api/" + resource + "/1", type, xml).statusCode(), resource + type);
            }
        }
    }

    private HttpResponse<String> send(String method, String path, String type, String body) throws Exception {
        return client.send(HttpRequest.newBuilder(URI.create("http://127.0.0.1:" + port + path))
            .header("Content-Type", type)
            .method(method, HttpRequest.BodyPublishers.ofString(body)).build(), HttpResponse.BodyHandlers.ofString());
    }
}
