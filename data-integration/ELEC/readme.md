#Data integration - Transformations
This directory contains the Spoon/Kettle-jobs and -transformations to get from the ELEC.txt the informations we need into the database.

## Start the transformations
Open the all_transformations job with Pentaho-Spoon.
Before we can start this transformation we have to set a *DATA_INPUT* variable.
Do this via *Edit*> *Set Environment Variables*. Set *DATA_INPUT* as *Name* and the path to the ELEC.txt as *Value*.

The path should be without filename or a trailing slash, for example *C:\pentaho\PSE\json_files* is a valid path.

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


### Facts

### Dimensions


