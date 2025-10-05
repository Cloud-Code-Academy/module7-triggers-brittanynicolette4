trigger AccountTrigger on Account (before insert, after insert) {
if (Trigger.isBefore && Trigger.isInsert) {
    for (Account a : Trigger.new) {
        if (a.Type == null) {
            a.Type = 'Prospect';
        }
        if (a.ShippingAddress ==  null) {
            a.BillingStreet = a.ShippingStreet;
            a.BillingCity = a.ShippingCity;
            a.BillingState = a.ShippingState;
            a.BillingPostalCode = a.ShippingPostalCode;
            a.BillingCountry = a.ShippingCountry;
        }

        if (a.Phone != null && a.Website != null && a.Fax != null){
            a.Rating = 'Hot';
        }
    }
}
if (Trigger.isAfter && Trigger.isInsert) {
    List<Contact> contacts = new List<Contact>();
    for (Account a : Trigger.new) {
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'DefaultContact';
        c.Email = 'default@email.com';
        contacts.add(c);
    }
    insert contacts;
}
}
