import java.io.StringReader;
import java.nio.file.Files;
import java.nio.file.Path;
import org.xml.sax.InputSource;
import org.xml.sax.helpers.DefaultHandler;
import org.glassfish.jaxb.core.v2.util.XmlFactory;

// Benign local fixture only. Exercise the factories named in the JAXB advisory.
public class XmlFactoryProbe {
    public static void main(String[] args) throws Exception {
        boolean expectedBlock = args[0].equals("blocked");
        Path fixture = Files.createTempFile("c06-xml-", ".txt");
        Files.writeString(fixture, "C06_ONLY_SENTINEL");
        String xml = "<!DOCTYPE root [<!ENTITY external SYSTEM '" + fixture.toUri()
            + "'>]><root>&external;</root>";
        try {
            var dom = XmlFactory.createDocumentBuilderFactory(false).newDocumentBuilder();
            if (!dom.parse(new InputSource(new StringReader("<root>ok</root>")))
                    .getDocumentElement().getTextContent().equals("ok")) throw new AssertionError();
            boolean domBlocked = false;
            try {
                String value = dom.parse(new InputSource(new StringReader(xml))).getDocumentElement().getTextContent();
                if (!value.equals("C06_ONLY_SENTINEL")) throw new AssertionError(value);
            } catch (org.xml.sax.SAXParseException e) {
                if (!e.getMessage().contains("accessExternalDTD")) throw e;
                domBlocked = true;
            }
            var reader = XmlFactory.createParserFactory(false).newSAXParser().getXMLReader();
            StringBuilder text = new StringBuilder();
            reader.setContentHandler(new DefaultHandler() {
                public void characters(char[] ch, int start, int length) { text.append(ch, start, length); }
            });
            boolean saxBlocked = false;
            try { reader.parse(new InputSource(new StringReader(xml))); }
            catch (org.xml.sax.SAXParseException e) {
                if (!e.getMessage().contains("accessExternalDTD")) throw e;
                saxBlocked = true;
            }
            if (!saxBlocked && !text.toString().equals("C06_ONLY_SENTINEL")) throw new AssertionError(text);
            if (domBlocked != expectedBlock || saxBlocked != expectedBlock) throw new AssertionError("Unexpected XML behavior");
            System.out.println("PASS mode=" + args[0] + " DOM=" + domBlocked + " SAX=" + saxBlocked + " normalXML=OK");
        } finally { Files.deleteIfExists(fixture); }
    }
}
