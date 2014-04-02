global class BatchHandler implements Database.Batchable<SObject>, Database.Stateful
{
    private IBatchHelper helper;

    public BatchHandler( IBatchHelper helper )
    {
        this.helper = helper;
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator( helper.getQuery() );
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope)
    {
        helper.execute( bc, scope );
    }

    global void finish(Database.BatchableContext bc)
    {
        helper.finish( bc, bc.getJobId() );
    }
}