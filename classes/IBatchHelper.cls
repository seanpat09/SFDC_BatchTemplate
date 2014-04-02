public interface IBatchHelper
{
    String getQuery();
    void execute( Database.BatchableContext bc, List<sObject> scope );
    void finish( Database.BatchableContext bc, Id jobId );
}