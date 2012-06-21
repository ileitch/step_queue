# StepQueue

A lock-free and wait-free out-of-order queue.

## Do you care about strict ordering?

If not, then you can remove locking and wait (CAS) and use a much simpler implementation.