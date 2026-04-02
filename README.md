# Immunisation Completeness sql-data-migration-patterns
ETL transformation and data validation patterns to determine Childhood Imms Completeness

- **Rule-Based Transformation**  
  Applying business logic to determine status, completeness, or eligibility based on defined rules.

- **Cohort & Window Logic**  
  Evaluating records against time-based conditions 

- **Aggregation & Status Calculation**  
  Rolling up granular data into meaningful outputs for reporting.

## Example Use Case

The included SQL demonstrates a transformation pipeline where:

- Records are assessed against rule definitions  
- Valid events are identified within defined time windows  
- Results are aggregated into structured outputs for reporting  

## Notes
- The focus is on transformation patterns rather than domain-specific implementation  
