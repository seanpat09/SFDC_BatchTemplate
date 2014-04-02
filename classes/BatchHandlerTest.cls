@isTest
private class BatchHandlerTest
{
    public static Boolean getQueryCalled = false;
    public static Boolean executeCalled = false;
    public static Boolean finishCalled = false;
    
    public with sharing class BatchHelperMock implements IBatchHelper
    {
        public String getQuery()
        {
            getQueryCalled = true;
            return 'SELECT Id FROM User';
        }

        public void execute( Database.BatchableContext bc, List<sObject> sObjects )
        {
            executeCalled = true;
        }

        public void finish( Database.BatchableContext bc, Id jobId )
        {
            finishCalled = true;
        }
    }
    
    static testMethod void executeBatch()
    {
        BatchHelperMock mock = new BatchHelperMock();
        Test.startTest ();
            BatchHandler batch = new BatchHandler( mock );
            Database.executeBatch(batch);
        Test.stopTest ();

        System.assert( getQueryCalled, 'getQuery should have been called by the helper');
        System.assert( executeCalled, 'execute should have been called  by the helper');
        System.assert( finishCalled, 'finish should have been called  by the helper');
    }
}