public with sharing abstract class StandardBatchFinish implements IBatchHelper
{
    @TestVisible static final String BATCH_JOB_EMAIL_BODY = '{0} processed {1} batches with {2} failures.\n' +
                                                            'The following errors occurred:\n' +
                                                            '{3}';
    protected final String BATCH_JOB_TITLE;
    @TestVisible protected List<String> errors;

    public StandardBatchFinish( String batchJobTitle )
    {
        this.BATCH_JOB_TITLE = batchJobTitle;
        this.errors = new List<String>();
    }

    public void finish( Database.BatchableContext bc, Id jobId )
    {
        if( hasNoErrors() ) return;
        sendErrorEmail( jobId );
    }

    @TestVisible Boolean hasNoErrors()
    {
        return this.errors.isEmpty();
    }

    @TestVisible void sendErrorEmail( Id jobId )
    {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, TotalJobItems, CreatedBy.Id
                            FROM AsyncApexJob
                            WHERE Id = :jobId ];
        Messaging.SingleEmailMessage mail = buildErrorEmail( job.CreatedBy.Id, job.status, job.TotalJobItems, job.NumberOfErrors );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @TestVisible private Messaging.SingleEmailMessage buildErrorEmail( Id targetId, String status, Integer totalJobItems, Integer numberOfErrors )
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId( targetId );
        email.setSaveAsActivity( false );
        email.setSubject( BATCH_JOB_TITLE + status);
        email.setPlainTextBody( String.format( BATCH_JOB_EMAIL_BODY,
                                               new List<String>{ BATCH_JOB_TITLE,
                                                                 String.valueOf(totalJobItems),
                                                                 String.valueOf(numberOfErrors),
                                                                 String.join( errors, '\n') } )
                              );
        return email;
    }
}