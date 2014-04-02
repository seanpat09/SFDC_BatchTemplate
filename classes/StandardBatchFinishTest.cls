@isTest
private class StandardBatchFinishTest
{
    public class BatchHelperExtensionMock extends StandardBatchFinish
    {
        public BatchHelperExtensionMock( String batchTitle ){ super( batchTitle ); }
        public String getQuery(){ return 'SELECT Id FROM Account'; }
        public void execute( Database.BatchableContext bc, List<sObject> sObjects ){}
    }

    static testMethod void finish_hasErrors()
    {
        StandardBatchFinish helper = new BatchHelperExtensionMock( 'Dummy Title' );
        BatchHandler batch = new BatchHandler( helper );
        helper.errors.add('An error');
        Database.executeBatch(batch);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, TotalJobItems, CreatedBy.Id
                            FROM AsyncApexJob LIMIT 1][0];
        Test.startTest();
            Integer emailInvocationsBefore = Limits.getEmailInvocations();
            helper.finish( /* Database.BatchableContext */ null, job.Id );
            Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assert( emailInvocationsBefore < emailInvocationsAfter, 'An email should have been sent out' );
    }

    static testMethod void finish_NoErrors()
    {
        StandardBatchFinish helper = new BatchHelperExtensionMock( 'Dummy Title' );
        BatchHandler batch = new BatchHandler( helper );
        Database.executeBatch(batch);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, TotalJobItems, CreatedBy.Id
                            FROM AsyncApexJob LIMIT 1][0];
        Test.startTest();
            Integer emailInvocationsBefore = Limits.getEmailInvocations();
            helper.finish( /* Database.BatchableContext */ null, job.Id );
            Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals( emailInvocationsBefore, emailInvocationsAfter, 'An email should have not been sent out' );
    }


    static testMethod void hasNoErrors_NoErrors()
    {
        StandardBatchFinish helper = new BatchHelperExtensionMock( 'Dummy Title' );
        Test.startTest();
            Boolean hasNoErrors = helper.hasNoErrors();
        Test.stopTest();
        System.assert( hasNoErrors, 'The helper should be marked as not having errors' );
    }

    static testMethod void hasNoErrors_ErrorsExist()
    {
        StandardBatchFinish helper = new BatchHelperExtensionMock( 'Dummy Title' );
        helper.errors = new List<String>{'An Error'};
        Test.startTest();
            Boolean hasNoErrors = helper.hasNoErrors();
        Test.stopTest();
        System.assertEquals( false, hasNoErrors, 'The helper should be marked as having errors' );
    }

    static testMethod void sendErrorEmail()
    {
        StandardBatchFinish helper = new BatchHelperExtensionMock( 'Dummy Title' );
        BatchHandler batch = new BatchHandler( helper );
        Database.executeBatch(batch);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, TotalJobItems, CreatedBy.Id
                            FROM AsyncApexJob LIMIT 1][0];
        Test.startTest();
            Integer emailInvocationsBefore = Limits.getEmailInvocations();
            helper.sendErrorEmail( job.Id );
            Integer emailInvocationsAfter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assert( emailInvocationsBefore < emailInvocationsAfter, 'An email should have been sent out' );
    }

    static testMethod void buildErrorEmail()
    {
        final String BATCH_TITLE = 'Test Batch';
        final String STATUS= 'Status';
        final Integer TOTAL_JOB_ITEMS = 10;
        final Integer NUM_ERRORS = 15;
        final List<String> ERRORS = new List<String>{'Error 1', 'Error 2'};

        StandardBatchFinish helper = new BatchHelperExtensionMock( BATCH_TITLE );
        helper.errors = ERRORS;
        
        Test.startTest ();
            Messaging.SingleEmailMessage email = helper.buildErrorEmail( UserInfo.getUserId(), STATUS, TOTAL_JOB_ITEMS, NUM_ERRORS );
        Test.stopTest();
        
        System.assertNotEquals(null, email, 'An email should have been returned' );

        String expectedBody  = String.format( StandardBatchFinish.BATCH_JOB_EMAIL_BODY, 
                                              new List<String>{
                                                BATCH_TITLE,
                                                String.valueOf(TOTAL_JOB_ITEMS),
                                                String.valueOf(NUM_ERRORS),
                                                String.join( ERRORS, '\n') }
                                             );
        System.assertEquals( expectedBody, email.getPlainTextBody(), 'The email body should be set correctly' );
        System.assertEquals( UserInfo.getUserId(), email.getTargetObjectId(), 'The target object id should be set correctly' );
        System.assertEquals( false, email.getSaveAsActivity(), 'The email should not save as activity' );
        System.assertEquals( BATCH_TITLE + STATUS, email.getSubject(), 'The email subject should be set correctly' );
    }
}