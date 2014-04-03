@isTest
public class BatchSchedulerMock extends BatchScheduler
{
    public BatchSchedulerMock( Integer minutes, String title ){ super( minutes, title ); }
    public void execute(SchedulableContext SC){}
}