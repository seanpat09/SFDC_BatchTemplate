@isTest
private class BatchSchedulerTest
{
    static final String SCHEDULABLE_TO_SCHEDULE = 'BatchSchedulerMock'; 
    static final String BATCH_TO_SCHEDULE = 'BatchHandler'; 
    static final Integer RESCHEDULE_MINUTES = 10;
    static final String TITLE = 'Test Title';

    public with sharing class BatchHelperMock implements IBatchHelper
    {
        public String getQuery() { return 'SELECT Id FROM Account'; }
        public void execute( Database.BatchableContext bc, List<sObject> sObjects ){}
        public void finish( Database.BatchableContext bc, Id jobId ){}
    }
    
    static testMethod void constructor() 
    {
        Test.startTest(); 
            BatchScheduler scheduler = new BatchSchedulerMock( RESCHEDULE_MINUTES, TITLE );
        Test.stopTest(); 

        System.assertEquals( TITLE, scheduler.title, 'The title on the scheduler should be set correctly' );
        System.assertEquals( RESCHEDULE_MINUTES, scheduler.minutesBeforeReschedule,
            'The minutesBeforeReschedule on the scheduler should be set correctly' );
    } 
    
    static testMethod void scheduled_BatchScheduled() 
    {
        BatchScheduler scheduler = new BatchSchedulerMock( RESCHEDULE_MINUTES, TITLE );

        Test.startTest(); 
            scheduler.schedule( new BatchHelperMock() );
            ApexClass batchClass = [SELECT Id FROM ApexClass WHERE Name=:BATCH_TO_SCHEDULE]; 
            List<AsyncApexJob> batches = [SELECT ApexClassId FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClassId = :batchClass.Id]; 
            System.assertEquals(1, batches.size(), 'There should be one scheduled batch of the proper class'); 
        Test.stopTest(); 
    } 

    static testMethod void testScheduleRetry() 
    {
        BatchScheduler scheduler = new BatchSchedulerMock( RESCHEDULE_MINUTES, TITLE );
        ApexClass schedulableClass = [SELECT Id FROM ApexClass WHERE Name=:SCHEDULABLE_TO_SCHEDULE]; 

        Test.startTest(); 
            scheduler.scheduleRetry(); 
        Test.stopTest(); 

        Integer numberOfScheduled = [SELECT count() FROM AsyncApexJob WHERE JobType='ScheduledApex' AND ApexClassId = :schedulableClass.Id]; 
        System.assertEquals(1, numberOfScheduled, 'There should be one retry scheduled'); 
    }
}