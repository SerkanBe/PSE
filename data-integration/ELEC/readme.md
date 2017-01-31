#Data integration - Transformations
This directory contains the Spoon/Kettle-jobs and -transformations to get from the [ELEC.txt](http://api.eia.gov/bulk/ELEC.zip) the informations we need into the database.

## Start the transformations
Open the all_transformations job with Pentaho-Spoon.
Before we can start this transformation we have to set a *DATA_INPUT* variable.
Do this via *Edit*> *Set Environment Variables*. Set *DATA_INPUT* as *Name* and the path to the ELEC.txt as *Value*.

The path should be without filename or a trailing slash, for example *C:\pentaho\data-integration\json_files* is a valid path.

When that's done you can click the start button and the transformation will start.
If you get an error, make sure you've set up the database and installed the drivers correctly (See the database-folder).

After the jobs ran you can check the database. You will see a lot of *NULL* values, but don't be alarmed, thats normal.
Those are rows with missing or incomplete data, which we didn't bother to fix since they're just a small portion of the data.


## Jobs
We have 3 jobs:
1. **All Transformations** *(all_transformation.kjb)*

   This calls the splitting transformation *(splitting.ktr)* and the other 2 jobs

2. **Transform Facts** *(transform_facts.kjb)*

   This will start the transformations of the facts we have.
   1. Consumption *(consumption.ktr)*
   2. Net generation *(elec_net_gen.ktr)*
   3. Retail *(elec_retail.ktr)*
   4. Plant generation *(plant_gen.ktr)*
   5. Plant consumption *(plant_con.ktr)*
      
   If you want to read more facts out of the file, this is the place to call you transformations.
   Also Note that most of the dimensions aren't set after the facts are transformed. The dimensions are set in their own
   transformation, and will be attached to the facts after that.

3. **Transform Dimensions** *(transform_dimensions.kjb)* 
    
    This job processes the categories (which we have extracted in the splitting process) and after that
     create the dimensions. After the dimensions are inserted in their tables the facts will get their dimension values.
     This is necessary because of how the dimension information is stored in the original file.
     
     So first categories is started, then the dimensions:
      0. Categories *(categories.ktr)*
      1. Fuels *(fuel.ktr)*
      2. Generation and Consumption sectors *(gen_con_sector.ktr)*
      3. Retail sectors *(retail_sector.ktr)*
      4. plant *(plant.ktr)*
      


## Transformations
This section will try and explain how the transformations work and why they were implemented like they are.
Hopefully you'll be able to use this information to be able to fix and/or add more features.
### Helpers
We have 2 transformations which process neither Facts nor Dimensions. 
They help us to get the data in a form we can work with later.

#### Splitting
In splitting we're just splitting (as the name suggests) the ELECT.txt, which is about 800MB right now, into separate files we can process. In theory in parallel, but that didn't work out that well.

This job has basically 2 rows of regex-filters, and some minor data-modifications.
The first row filters by the first key in the json object. We have 4 cases of interest:
 1. Series: series_id is here the first key
 2. Categories: category_id
 3. Geosets: geoset_id (We don't use this group)
 4. Relations: relation_id (Also not used at all)
 5. none of the above: in that case we just print it out to the console. Right now there is no case we're missing.
 
All groups, except series, is beeing written directly into an own file, like *category.txt*, in the DATA_INPUT directory.

Series is beeing manupilated and further filtered into more groups.
 
 ##### Series
After the first filter we have the following steps:
 - JSON Input: Here we read some properties common among the series objects
   * Series ID (series_id)
   * Units (units)
   * Frequency (f)
   * State (geography)
 - We filter the rows with quarter and annual information. We can and will aggregate those ourselves if we need them.
 - We filter out rows with multiple states. We can't handle that properly, and for our purposes we can ignore this kind of data.
 - Also filter out "USA" as state. Again: If we want aggregates, we will aggregate.
 
 After these steps we're at the second row of filters. These will filter/group the series by their series IDs into:
1. Generation 
2. Consumption
3. Retail
4. Plant
   1. Plant Generation
   2. Plant Consumption
   
The plant series_id have a lot in common, so the first filter just checks if it's a plant-row. And the two after that see what kind of plant-row that is.
 
Each of these filters filter out a lot of aggregation and BTU-Rows which we don't need/want.
We could leave those in and filter them out on display. But the smaller the files after the splitting, the faster the transformations are.


##### What are these "dummy steps"?
They're leftovers from experimenting with "multithreding" the filters. Just ignore those, if the filter before that doesn't have a small number (like x4) at the top left corner´.


#### Categories
This transformation is here just to keep all of this future-proof. The
goal of this is to have the tree-structure in the database in a way we
can easily query for "All fuel types which are used in electricity generation".

Originally this isn't that easy, since each category only knows its parent,
but now the full path up to the root. This is solved by this transformation.

For each category the path to the root is determined and saved with the category.
Along with all the child-series_ids, where we later assign the categories to.

That is done as follows:
 - Load all the categories and count the distance from the root for each
 - We filter out the root by distance (>0)
 - After sorting the rows by their distance, we group them by the category_id and concatenate the category_ids with '/' in between.
 - We merge result of this with another sorted full-list of categories
 - Now we have the original category-data and their path
 - We add a trailing slash to the path, so we are able to query for '/%'

 In this transformation we also fill the category-tree table, but that is only used for development/debug purposes.


### Facts
The consumption, electricity generation and retail have basically the same transformation-process.
Plant generation and Plant consumption have more steps, but also share a common structure.

As for the first transformations, the steps are the following:
 - Load the corresponding file
 - Parse the json object, and read the fields we need (we load all of the fields, but don't use all of them)
 - The step called *extract date&amount* loads the elements from the *data* array of the row.
 For that we set the field *data* as source and set the paths to the columns. For *date* this is `$.[*][0]` and for *amount* it's `$.[*][1]`.
 The key here is using `$.[*]` to iterate through each element of the *data* array. This can't be done in the first json-parse, since we have multiple items per row.
 - *rename states* just renames the *geography* values by replacing 'USA-' with 'US-'. We did this just so we can work with jvectormap more easily.
 - *get date-segments* reads the creates the month, quarter and year information out of the *date* field.
 - The two combination lookup steps *Period* and *State* create and reference the entries for (time)-periods (because using time causes problems with mysql) and states.
 - After that the row is written into the table of the fact.

For the plant transformations we have all of the above plus some additional steps. Here are the additional ones:
 - In *Extract plant_id* (after *rename states*) we extract the *plant_id* from the *series_id* using a regex.
 - After that we extract *plant_name*,*plant_fuel* and *plant_type* from the *plant_name*, also using a regex.
 - Then the combination-lookups for plants and plant_fuels do their job of creating and referencing the dimensions in their tables.
 - Now the row goes into the corresponding plant table.

### Dimensions
For the dimensions we have four transformations: *fuel*, *Generation/Consumption Sector*, *retail_sector* and *plant*.
The first three do basically the same:
 - Get the dimension-values from the categoy-table with a query, using `child.path LIKE '371/0/1/3/%/'`. This gets all the categories which come after `371/0/1/3` but have no own children.
 - Make sure we don't set the root as parent (as the root itself isn't a value of the dimension)
 - Lookup/Create the entry for that value in the dimension.
 - Read the `series_id`s from the row and group them by fuel. We group them so we have one large `UPDATE` per dimension-value instead of (potentially) millions of single-row-UPDATEs.
 - After all of the rows have been updated remove the rows without a value for that dimension.

There are slight differences. For example *fuel* does use the *Lookup/Combine* step, where the other two create the rows in the dimension table with *Insert/Update*.
This is probably because having the *Lookup/Combine* caused some dead-locks on the table. So we decided to use the other method with a blocking/waiting step.

The transformations for the plants only updates the dimensions-table.
 - Parse the json and get all the fields.
 - Extract plant_id and information from the name (see plant transformations unter **Facts**)
 - group the rows by plant-id. This is done in memory, meaning all the rows are read into memory and grouped after that. So might need a lot of ram for this step.
 - After the grouping we do the state-renaming (replace 'USA-' with 'US-') and the usual dimension-refrencing (*state*,*fuel*,*type*).


Also there is a construction handling missing lat/lon values:
 - If the first *json parse* fails, we redirect the row to a second *json parse*. Here the lat/lon fields aren't parsed.
 - We set them manually to 0, and after that to `NULL` with a *Null if...* step. (There was no way to directly set them to `NULL`)
 - After that the row is processed as the other rows are.


# Issues you might encounter
## Database Deadlocks
 When using the *lookup/combination* steps we got sometimes deadlocks in the database. Meaning the dimensions where waiting for a lock in the facts to get freed, while the fact was waiting for the dimensions to be freed.
 As this came up which the dimension transformations we replaced the *lookup/combination* with a *insert/update* when it was possible (if we knew the ID/used the category-id)
 Also we've set the commit-sizes for the *lookup/combination* steps pretty low (mostly to 1), so those wouldn't wait for more to come for a commit, while the facts wait for the dimensions to get filled up.
 This causes the rows to pile up in front of *lookup/combination* and the whole transformation comes to an halt.

## What are the "paths" of the categories good for?
 Since the categories have parents (and therefore children), it would be the easiest way to span the tree of categories and traverse that.
 For example the task `get all fuels used to generate electricity, regardless of sector` is a bit tricky, and we would have to list them all and update them if there is a new type of fuel.
 Or we use the tree-like structure, create a table where we have the paths of each fuel-type, so we can go for a path like mentioned earlier : `371/0/1/3/%/`
  - 371 : root (Don't ask me why the root is 371...)
  - 0 : Electricity
  - 1 : Net Generation
  - 3 : By Fuel Type
 So this will result in a list with all the fuel types which are used to generate electric power. There will be duplicate names, since all of the date is also grouped by sector. (`371/0/1/2/%/`)
 But with a bit of group-by magic and concatenating this is solvable and easier to handle than a list one has to keep updated.

## What is the *parent* column in the fuel-table for?
We were kind of fooled by the filter used in the [electricity browser](http://www.eia.gov/electricity/data/browser/) of the EIA.
There the fuel-types are in a tree-structure, so we assumed the same structure would be in the ELEC.txt file. But it wasn't.
So, this field isn't used anywhere at any time. Would have been great for queries like 'Give me all solar generation' so have a parent 'All solar'... but that's not the case.

## I have a lot of plants with `NULL` in all of the dimensions
That's a bug we couldn't figure out, and it didn't bug us that much. Since the plants are in there with data also.
