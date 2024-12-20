/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable {

    // Member variable to store the accounts
    private Map<Id,Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id,Account> accounts) {

        // Store the accounts in a member variable
        this.accounts = accounts;
    }

    // Method to queue the job
    public static void enqueueJob() {

        //  Create a Map of Accounts to pass to the constructor
        Map<Id, Account> accMap = new Map<Id,Account>();
        
        // Get 10 accounts with Next Step populated
        List<Account> accs = new List<Account>([SELECT Id, Next_Step__c FROM Account WHERE Next_Step__c != NULL LIMIT 10]);

        // If there are any accounts, queue the job using System.enqueueJob
        for (Account acc : accs) {
            accMap.put(acc.Id, acc);   // for every acc that populates the list, put it in the above map
        }

        //google how to make new instances for Apex CLass
        //Coding w/ Force Instantiate a Class



        // help explain this        &&&&&&
        // If there are accounts in the Map, queue the job using System.enqueueJob
        if (!accMap.isEmpty()) {
            System.enqueueJob(new NextStepQueueable(accMap));
        }
    }

   
    //Method to execute the queueable job
     

    public void execute(QueueableContext context) {
        for (Account acc : accounts.values()) {
            makeNextStepNull(acc);
        }
        update accounts.values();
        
        List<Opportunity> oppyList = [SELECT Id, Name, NextStep FROM Opportunity WHERE AccountId IN : accounts.keySet()];
        for (Opportunity opp : oppyList) {
            makeNextStepNull(opp);
        }
        update oppyList;

        enqueueJob();
        
    }
    
    private static void makeNextStepNull(Account acc){
        acc.Next_Step__c = null;
    }
    private static void makeNextStepNull(Opportunity opp){
        opp.NextStep = null;
    }

/*


    //[public | private ] [static] data_type execute (input parameters) {
        // Get the accounts from the member variable

            // Remove the Next Step using the helper method

        // Update the accounts

        // Get the opportunities related to the accounts

            // Remove the Next Step using the helper method

        // Update the opportunities

        // Call the enqueueJob method to queue another job to process more records.
    //}

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    
*/
}
 