public class XMLSerializer {
    
    private static final List<String> RESERVED_WORDS = new List<String>{ 'number', 'abstract', 'after', 'any', 'activate', 'as', 'asc', 'autonomous', 'begin', 'before', 'bigdecimal', 'break', 'bulk', 'case', 'cast', 'catch', 'char', 'class', 'collect', 'commit', 'const', 'continue', 'default', 'delete', 'desc', 'do', 'else', 'enum', 'exit', 'export', 'extends', 'false', 'final', 'finally', 'float', 'for', 'global', 'goto', 'group', 'hint', 'if', 'implements', 'import', 'inner', 'insert', 'instanceof', 'interface', 'into', 'join', 'loop', 'merge', 'new', 'null', 'number', 'of', 'on', 'outer', 'override', 'package', 'parallel', 'pragma', 'private', 'protected', 'public', 'retrieve', 'return', 'returning', 'search', 'select', 'short', 'sort', 'stat', 'static', 'super', 'switch', 'synchronized', 'testmethod', 'this', 'throw', 'transaction', 'trigger', 'true', 'try', 'type', 'transient', 'undelete', 'update', 'upsert', 'virtual', 'webservice', 'while', 'when' };
    public static final String NULL_KEYWORD = '{!null}';

    public static String serialize(Object obj){
        return serialize(obj, false, false);
    }

    public static String serialize(Object obj, boolean supressNullValues){
        return serialize(obj, false, supressNullValues);
    }

    public static String serializePretty(Object obj){
        return serialize(obj, true, false);
    }

    public static String serializePretty(Object obj, boolean supressNullValues){
        return serialize(obj, true, supressNullValues);
    }

    public static Object deserialize(String xml, Type apexType){
        if(xml == null){
            return null;
        }
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        return JSON.deserialize(JSON.serialize(deserialize(doc, true)), apexType);
    }

    public static Object deserialize(Dom.Document xmlDocument, Type apexType){
        return JSON.deserialize(JSON.serialize(deserialize(xmlDocument, true)), apexType);
    }
    
    public static Object deserializeUntyped(String xml){
        if(xml == null){
            return null;
        }
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        return deserialize(doc, false);
    }

    public static Object deserializeUntyped(Dom.Document xmlDocument){
        return deserialize(xmlDocument, false);
    }



    private static String serialize(Object obj, Boolean pretty, boolean supressNull){
        String xmlBody = '';
        if(obj == null){
            return xmlBody;
        }
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        for(String xmlFieldName : data.keySet()){
            Object value = data.get(xmlFieldName);
            xmlBody += getXMLField(xmlFieldName, value, (pretty) ? 0 : -1, supressNull);
        }
        return xmlBody;
    }

    private static String getXMLField(String xmlFieldName, Object value, Integer indent, boolean supressNull){
        String xmlField = '';
        String formatedField = formatXMLName(xmlFieldName);
        Integer newIndent = (indent >= 0) ? indent + 1 : -1;
        if(value instanceof List<Object>){
            List<Object> dataList = (List<Object>) value;
            for(Object obj : dataList){
                xmlField += getXMLField(xmlFieldName, obj, newIndent, supressNull);
            }
        } else if(value instanceof Map<String, Object>){
            Map<String, Object> dataMap = (Map<String, Object>) value;
            xmlField += getIndent(indent) + '<' + formatedField + '>';
            if (indent >= 0){
                xmlField += '\n';
            }
            for(String xmlSubfieldName : dataMap.keySet()){
                Object subfieldValue = dataMap.get(xmlSubfieldName);
                xmlField += getXMLField(xmlSubfieldName, subfieldValue, newIndent, supressNull);
            }
            xmlField += getIndent(indent) + '</' + formatedField + '>';
            if (indent >= 0){
                xmlField += '\n';
            }
        } else {
            if(value == NULL_KEYWORD || (value == null && !supressNull)){
                xmlField += '<' + formatedField + '/>';
                if (indent >= 0){
                    xmlField += '\n';
                }
            } else if(value != null) {
                xmlField += getIndent(indent) + '<' + formatedField + '>' + String.valueOf(value) + '</' + formatedField + '>';
                if (indent >= 0){
                    xmlField += '\n';
                }
            }
        }
        return xmlField;
    }

    private static String formatXMLName(String xmlFieldName){
        if(xmlFieldName != null && xmlFieldName.startsWith('x_')){
            xmlFieldName = xmlFieldName.substring(2);
        }
        return xmlFieldName;
    }

    private static String getIndent(Integer nTabs){
        if(nTabs > 0){
            String tab = '\t';
            return tab.repeat(nTabs);   
        }
        return '';
    }

    private static Object deserialize(Dom.Document doc, Boolean handleNames){
        if(doc == null){
            return null;
        }
        Dom.XmlNode rootNode = doc.getRootElement();
        return processNode(rootNode, handleNames);
    }

    private static Object processNode(Dom.XmlNode node, Boolean handleNames){
        if(node.getNodeType() == Dom.XmlNodeType.ELEMENT){
            String nodeName = processKey(node.getName(), handleNames);
            Map<String, Object> responseData = new Map<String, Object>();
            if(node.getChildElements().size() > 0){
                for(Dom.XmlNode childNode : node.getChildElements()){
                    String chidNodeName = processKey(childNode.getName(), handleNames);
                    if(childNode.getChildElements().size() > 0){
                        if(responseData.containsKey(chidNodeName)){
                            Object nodeData = processNode(childNode, handleNames);
                            Object storedData = responseData.get(chidNodeName);
                            if(storedData instanceOf List<Object>){
                                List<Object> dataList = (List<Object>) storedData;
                                dataList.add(nodeData);
                                responseData.put(chidNodeName, dataList);
                            } else {
                                List<Object> dataList = new List<Object>();
                                dataList.add(storedData);
                                dataList.add(nodeData);
                                responseData.put(chidNodeName, dataList);
                            }
                        } else {
                            responseData.put(chidNodeName, processNode(childNode, handleNames));
                        }
                    } else {
                        if(responseData.containsKey(chidNodeName)){
                            Object storedData = responseData.get(chidNodeName);
                            if(storedData instanceOf List<Object>){
                                List<Object> dataList = (List<Object>) storedData;
                                dataList.add(transformToDatatype(childNode.getText()));
                                responseData.put(chidNodeName, dataList);
                            } else {
                                List<Object> dataList = new List<Object>();
                                dataList.add(storedData);
                                dataList.add(transformToDatatype(childNode.getText()));
                                responseData.put(chidNodeName, dataList);
                            }
                        } else {
                            responseData.put(chidNodeName, transformToDatatype(childNode.getText()));
                        }
                    }
                }
            } else {
                responseData.put(nodeName, transformToDatatype(node.getText()));
            }
            return responseData;
        }
        return null;
    }

    private static Object transformToDatatype(String text){
        try {
            return Date.valueOf(text);
        } catch (Exception e) {}
        try {
            return Datetime.valueOf(text);
        } catch (Exception e) {}
        try {
            return Integer.valueOf(text);
        } catch (Exception e) {}
        try {
            return Long.valueOf(text);
        } catch (Exception e) {}
        try {
            return Double.valueOf(text);
        } catch (Exception e) {}
        if(text == 'true'){
            return true;
        } else  if(text == 'false'){
            return false;
        }
        return text;
    }

    private static String processKey(String fieldKey, Boolean handleNames){
        if(handleNames && RESERVED_WORDS.contains(fieldKey)){
            return 'x_' + fieldKey;
        }
        return fieldKey;
    }

}
