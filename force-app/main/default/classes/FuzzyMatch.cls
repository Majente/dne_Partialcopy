public class FuzzyMatch {
 /**
* Encode a word phonetically
* 'HeLLLL00 World!'
*  -> 'HLWRLD'
*    -> 'H40643'
*       Which is the same code as 'Hello World!'
*/
    public static string phonetic(string ip, integer max) {
        
        if (ip == null || ip == '') return '';
        
        string op = ip.toUpperCase();
        
        // Encode phonetically similar letters as same number
        op = op.replaceAll('[^BFPVCGJKQSXZDTLMNR]', '0');
        op = op.replaceAll('[BFPV]', '1');
        op = op.replaceAll('[CGJKQSXZ]', '2');
        op = op.replaceAll('[DT]', '3');
        op = op.replaceAll('[L]', '4');
        op = op.replaceAll('[MN]', '5');
        op = op.replaceAll('[R]', '6');
        
        // Remove double-letters
        string op2 = op.substring(0,1);
        for (integer i=1; i<op.length()-1; i++) {
            string c2 = op.substring(i,i+1);
            if (!op2.endsWith(c2)) op2 += c2;
            //system.debug('******'+op2);
        }
        
        // Limit length of code returned
        if (max > op2.length()) max = op2.length();
        
        // Keep first letter of original word
        op2 = ip.substring(0,1) + op2.substring(1, max);
        
        return op2;
    }
    
    // Convert nulls to empty strings
    private static string ops(string s) {
        return s == null?'':s;
    }
    
    /**
  * Return all accounts matching this address
  *  The field AnnualRevenue is misused to return the probability of match
  */
    public static List<Account> AccountsByAddress(String Name1) {
        
        List<Account> result = new List<Account>();
        
        List<Account> accs;
        Integer MAX = 50;
        accs = [SELECT Id, Name  FROM Account WHERE Name =: Name1 LIMIT :MAX];
        
        
        if (accs.size() == MAX) {
            // Too many, enforce name
            system.debug('Fuzzy postcode and city pre-selected too many(2)!');
            string Name4 = Name1.substring(0, 4)+'%';
            accs = [SELECT Id, Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry
                    FROM Account
                    WHERE Name LIKE :Name4
                    LIMIT :MAX];
        }
        system.debug('Fuzzy accounts pre-selected '+accs.size());
        
        String Name10   = phonetic(Name1, 10);
        system.debug('Name10='+Name10);
        
        String Name4   = phonetic(Name1, 4);
        system.debug('Name4='+Name4);
        
        for (Account acc: accs) {
            system.debug(acc);
            Boolean SameName     = (acc.Name == Name1);
            system.debug('SameName='+SameName);
            
            Boolean Like10Name   = (phonetic(acc.Name, 10) == Name10);
            system.debug('Like10Name='+Like10Name);
            
            Boolean Like4Name   = (phonetic(acc.Name, 4) == Name4);
            system.debug('Like4Name='+Like4Name);
            
            if (SameName)
                acc.AnnualRevenue = 100;
            else if (Like10Name ) acc.AnnualRevenue = 75;
            else if (Like4Name ) acc.AnnualRevenue = 50;
            else {
                // Probably not a duplicate
                system.debug('PROB=0');
                continue;
            }
            system.debug('PROB='+acc.AnnualRevenue);
            
            result.add(acc);
        }
        
        return result;
    }
    public static List<String> getFragments(String potentialName)
    {
        if (String.isBlank(potentialName)) return null;
        
        List<String> fragments = new List<String>();
        List<String> chunks = potentialName.split(' ');
        
        while (chunks.size() >= 2) // starting with one word should yield an empty result
        {
            String fragment = '';
            /*
            
            fragment += '%';
            fragment += chunks.remove(0);
            fragment += '%';
            fragments.add(fragment);
            */
            //fragment += '%';
            System.debug('=fragments=' + fragments);
            if (!fragments.isEmpty()) fragment += '%'; //No leading wildcard
            System.debug('=fragment=' + fragment);
            System.debug('=chunks=' + chunks);
            fragment += chunks.remove(0);
            System.debug('=fragment after remove=' + fragment);
            System.debug('=chunks after remove=' + chunks);
            fragment += ' ';
            fragment += chunks.get(0);
            System.debug('=fragment after get=' + fragment);
            if (chunks.size() > 1) fragment += '%'; // No trailing wildcard
            System.debug('=fragment= last + ' + fragment);
            fragments.add(fragment);
            
        }
        
        return fragments;
    }
}