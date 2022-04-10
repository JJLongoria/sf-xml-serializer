# [**XMLSerializer**](https://github.com/JJLongoria/sf-xml-serializer)

The XMLSerializer class has powerfull methods to **serialize** any Apex Class intance and **deserialize** any XML file or String (without sintax errors and root tag) into an Apex Class instance, like JSON Class provided by Salesforce. You can [**Serialize Pretty**](#serializeprettyxml) and [**Serialize Minified**](#serializexml) or serialize into [**full XML String**](#toxml) with **root tag and prolog** and [**Deserialize**](#deserialize) into a specific object or [**Deserialize Untyped**](#deserializeuntyped) into a `Map<String, Object>`.

## [**Serialize XML**](#serializexml)
Serialize any object into a Minified XML String.

For example, we want to serialize the next objects structure

```java
public class ObjectToSerialize {
    public String name;
    public String lastName;
    public Address address;
    public List<Product> products;
}

public class Address {
    public String street;
    public Integer number;
}

public class Product {
    public String name;
    public Double price;
}
```


```java
ObjectToSerialize obj = new ObjectToSerialize();
// Map the obj values
String xml = XMLSerializer.serialize(obj);        // To include null values
String xml = XMLSerializer.serialize(obj, false); // To supress null values

// If you want to include some null values, but not all, you can use the NULL_KEYWORD constant, like:

ObjectToSerialize obj = new ObjectToSerialize();
obj.lastName = XMLSerializer.NULL_KEYWORD;
// Map other fields
String xml = XMLSerializer.serialize(obj, false); // Suppress al null values, and put null values tags into XMLSerializer.NULL_KEYWORD mapped fields.

System.debug(xml);
```
```xml
<name>nameValue</name><lastName>nameValue</lastName><address><street>streetValue</street><number>10</number></address><products><name>nameValue</name><price>50.5</price></products><products><name>nameValue</name><price>52.5</price></products><products><name>nameValue</name><price>60.0</price></products>
```

## [**Serialize Pretty XML**](#serializeprettyxml)
Serialize any object into a Pretty XML String

```java
ObjectToSerialize obj = new ObjectToSerialize();
// Map the obj values
String xml = XMLSerializer.serializePretty(obj);        // To include null values
String xml = XMLSerializer.serializePretty(obj, false); // To supress null values

// If you want to include some null values, but not all, you can use the NULL_KEYWORD constant, like:

ObjectToSerialize obj = new ObjectToSerialize();
obj.lastName = XMLSerializer.NULL_KEYWORD;
// Map other fields
String xml = XMLSerializer.serializePretty(obj, false); // Suppress al null values, and put null values tags into XMLSerializer.NULL_KEYWORD mapped fields.

System.debug(xml);
```
```xml
<name>nameValue</name>
<lastName/> <!-- null value -->
<address>
    <street>streetValue</street>
    <number>10</number>
</address>
<products>
    <name>nameValue</name>
    <price>50.5</price>
</products>
<products>
    <name>nameValue</name>
    <price>52.5</price>
</products>
<products>
    <name>nameValue</name>
    <price>60.0</price>
</products>
```
## [**To XML**](#toxml)
Serialize any object into XML File String (with XML prolog and root tag)


## [**Deserialize**](#deserialize)
Deserialize any XML String or Dom.Document into specific object

## [**Deserialize Untyped**](#deserializeuntyped)
Deserialize any XML String or Dom.Document untyped into a Map<String, Object>