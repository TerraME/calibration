# Package calibration
_Antonio O. Gomes Jr, Pedro R. Andrade, Claus Aranha_


##Introduction


The Calibration [package](https://github.com/TerraME/terrame/wiki/Packages) was developed to facilitate the calibration process of environmental models. It offers a complete interface to calibrate, test, and evaluate [models](https://github.com/TerraME/terrame/wiki/Models) defined in TerraME.

This tool was developed as a package for [TerraME](https://github.com/TerraME/terrame/wiki), a modeling and simulation platform developed by INPE. This package can be used to calibrate models such as Amazon forest deforestation models, to test the model and to compare its results with real scenarios, adjusting its parameters.

The code of this package is open-source and is available in the [project page at GitHub](https://github.com/pedro-andrade-inpe/calibration).

##Classes
 The functionalities of this [package](https://github.com/TerraME/terrame/wiki/Packages) are implemented in three separate classes:
***
Goodness-Of-Fit, SaMDE (Self-Adaptive Mutation in the Differential Evolution), and Multiple-Runs.
***
 The [Goodness-of-Fit](https://github.com/pedro-andrade-inpe/calibration/wiki/1.1---Goodness-of-Fit) class implements metrics that evaluate the accuracy of a [model](https://github.com/TerraME/terrame/wiki/Models) when compared to a given reference.

 The [SaMDE](https://github.com/pedro-andrade-inpe/calibration/wiki/1.2-SaMDE) class executes the automatic calibration of a [model](https://github.com/TerraME/terrame/wiki/Models) using genetic algorithms. It returns the best set of parameters according to a criteria defined by the user.

 The [Multiple-Runs](https://github.com/pedro-andrade-inpe/calibration/wiki/1.3-MultipleRuns) class implements a variety of strategies to simulate a [model](https://github.com/TerraME/terrame/wiki/Models). It allows the modeller to compare results of different parameter sets, and to analyse the behaviour of a model under different scenarios.

##Usage
 To illustrate the use of our package, we will use the fireInTheForest `Model` (a model that simulates the spread of fire in a forest). The calibration package has classes to help with each of steps of calibrating a `Model TerraME` type. 

 First the model can be calibrated using the genetic algorithm in SaMDE. SaMDE receives some information such as the fireInTheForest `Model` object, the possible range for each of the model parameters, and a fitness function defined by the user. The fitness function is used by the genetic algorithm to evaluate the model and find the set of parameters that has the best fitness.

 To help in the creation of a fitness function there is the goodness-of-fit class. This class implements various methods to evaluate a model result. The result is compared with some other reference data provided by the user. The methods implemented by goodness-of-fit receive a `cellularSpace` as an argument, a TerraME structure useful for storing model results.
***
 A `cellularSpace` is a table containing a 2 dimensional grid of `Cells`. These cells are capable of storing arguments and interacting with each other. From the TerraME documentation:

`cellularSpace`: "A multivalued set of Cells. It can be retrieved from databases, files, or created directly within TerraME. Every Cell of a CellularSpace has an (x, y) location. The Cell with lower (x, y) represents the upper left location."

`Cell`: "A spatial location with homogeneous internal content. It is a table that may contain nearness relations as well as persistent and runtime attributes. Persistent attributes can be loaded from databases using CellularSpace, while runtime attributes can be created along the simulation."
***
 Finally, after the model has been calibrated, the MultipleRuns class can be used to execute the model using different strategies and scenarios to study its results.
 The MultipleRuns function receives a `Model` type, a table of possible parameters for the model, a strategy for the model's execution and one or more output functions.
***
Output: One or more functions defined by the user. Each function must receive an executed model and may be used to save and/or compare their results. The return value of these functions are in the multipleRuns output table.
***
 The MultipleRuns type creates a folder for each of the different simulations, so the results from output functions can be saved inside that folder. It returns a table indexed by execution order containing the initial value for each of the instantiated models, the return values of the output functions, and the folder name for each simulation.

##Installation
 To use any of the functions and types in this [package](https://github.com/TerraME/terrame/wiki/Packages), you must first download and install this package into your TerraME platform. This package is available for download on the releases tab of the git hub project.

 After downloading the .zip file, open the TerraME platform, select "install new package" and choose the "calibration.zip" file. To be able to use an installed package in your programs, you must first import it using:
> import("calibration")
