public with sharing abstract class BatchScheduler implements Schedulable
{
    @TestVisible static final Integer MAX_CONCURRENT_BATCH = 5;
    Integer minutesBeforeReschedule;
    public BatchScheduler( Integer minutes )
    {
        this.minutesBeforeReschedule = minutes;
    } 
    public void schedule( IBatchHelper helper, Integer batchSize )
    {
        Integer currentlyRunningBatches = [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex'
                                           AND (Status = 'Processing' OR Status = 'Preparing')];
        if( currentlyRunningBatches < MAX_CONCURRENT_BATCH )
        {
            BatchHandler batch = new BatchHandler( helper );
            Database.executeBatch( batch, batchSize );
        }
        else
        {
            scheduleRetry();
        }
    }

    public void schedule( IBatchHelper helper )
    {
        schedule( helper, 200 );
    }

    @TestVisible void scheduleRetry() 
    { 
        Datetime rescheduleDateTime = Datetime.now().addMinutes(minutesBeforeReschedule); 
        String timeForScheduler = rescheduleDateTime.format('s m H d M \'?\' yyyy'); 
        System.schedule('Case Hold Clear Job'+timeForScheduler, timeForScheduler, this); 
    } 
}