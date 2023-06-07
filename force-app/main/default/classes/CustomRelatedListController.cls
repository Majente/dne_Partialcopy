public class CustomRelatedListController {
    public String typeOf { get; set; }
    public String relatedField { get; set; }
    public Id relatedId { get; set; }

    public List<sObject> objects;

    public CustomRelatedListController() {}

    public List<sObject> getObjects() {
        return Database.query('SELECT Id, Name FROM ' + typeOf + ' WHERE ' + relatedField + ' = \'' + relatedId + '\'');
    }
}