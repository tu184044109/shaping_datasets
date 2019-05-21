Supplementary material for the paper "A Probabilistic Approach to People-Centric Photo Selection and Sequencing"
----------------------------------------------------------------------------------------------------------------

This folder demonstrates the proposed Mixed Integer Linear Programming (MILP) dataset shaping technique on 2 different datasets, using Matlab's "intlinprog" solver.


CONTENTS
--------
- Script "test_replicate_Fig2.m" replicates an extended version of Fig.2 (on 100 random 2-dimensional datapoints).
- Script "test_replicate_Fig3.m" replicates an extended version of Fig.3 (on 11K 6-dimensional datapoints of various distributions).
- Function "SHAPE.m" is the actual implementation of the MILP method proposed in the paper, which is called by the 2 other test scripts. This function can be used with any other dataset that you may wish to shape.
- Data files "DATA_random_6D.mat" and "DATA_random_2D.mat" contain random datapoints used in the previous 2 scripts. 


DEPENDENCIES
------------
Function "SHAPE.m" requires Matlab's "intlinprog" solver, which is part of the Optimization toolbox. 


CITATION
--------
If you use this code for research puproses please cite the following publication:
Vonikakis, V., Subramanian, R., Arnfred, J., & Winkler, S. (2017). A Probabilistic Approach to People-CentricPhoto Selection and Sequencing. IEEE Transactions in Multimedia. DOI: 10.1109/TMM.2017.2699859


CONTACT
-------
For anyquestions/suggestions, please contact me at: bbonik@gmail.com



