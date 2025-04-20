# Understanding Rego

## Key Concepts in Rego

1. **Declarative Language**: Rego is declarative, focusing on what the result should be rather than how to compute it.

2. **Rules and Queries**: Rego uses rules to define policies and queries to ask questions about data.

3. **Data-Driven**: Policies are evaluated against input data and optional external data.

4. **Logical Foundations**: Based on Datalog, a subset of Prolog.

## Differences from Go and Traditional Languages

1. **Execution Model**: 
   - **Rego**: Evaluates rules and queries against data.
   - **Go/Traditional**: Executes statements sequentially.

2. **State Management**:
   - **Rego**: Stateless, relies on input data.
   - **Go/Traditional**: Can maintain state between function calls.

3. **Control Flow**:
   - **Rego**: Uses logical conditions and set operations.
   - **Go/Traditional**: Uses loops, conditionals, and function calls.

4. **Purpose**:
   - **Rego**: Specifically designed for policy definition and evaluation.
   - **Go/Traditional**: General-purpose programming.

## Components in Rego

1. **Package Declaration**:
   ```rego
   package region
   ```
   Defines the namespace for the rules in the file.

2. **Imports**:
   ```rego
   import rego.v1
   import input as tfplan
   import data.parameters
   ```
   Brings in external data or aliases.

3. **Rules**:
   ```rego
   check_region := {"result": true, "message": message} if {
       // conditions
   } else := {"result": false, "message": message} if {
       // alternative conditions
   }
   ```
   Defines logical conditions and results.

4. **Variables**:
   ```rego
   message := sprintf("Region %s is valid", [tfplan.variables.region.value])
   ```
   Assigned within rule bodies.

5. **Built-in Functions**:
   ```rego
   sprintf("Region %s is valid", [tfplan.variables.region.value])
   ```
   Rego provides various built-in functions like `sprintf`.

6. **Operators**:
   ```rego
   tfplan.variables.region.value in parameters.valid_regions
   ```
   `in` is a membership operator. Others include `==`, `!=`, `<`, `>`, etc.

7. **Data References**:
   ```rego
   tfplan.variables.region.value
   parameters.valid_regions
   ```
   Dot notation to access nested data.

8. **Sets and Arrays**:
   ```rego
   [tfplan.variables.region.value, parameters.valid_regions]
   ```
   Used for grouping data.

## Key Things to Remember

1. **Partial Evaluation**: Rules can succeed partially, allowing for incremental policy evaluation.

2. **No Side Effects**: Rego doesn't modify data; it only evaluates and returns results.

3. **Unification**: Variables are unified with values, not assigned like in imperative languages.

4. **Set-based**: Many operations in Rego work on sets of values.

5. **Short-circuiting**: Evaluation stops as soon as a condition is met.

6. **Default Values**: You can specify default values for rules.

7. **Modularity**: Policies can be split across multiple files and packages.

When programming in Rego, focus on expressing the policy conditions clearly, understand how data flows through the rules, and leverage built-in functions and operators to create concise and effective policies.

