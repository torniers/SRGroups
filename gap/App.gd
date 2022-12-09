
#! @Description
#! Runs the app to visualise the subgroup lattice for groups of degree k in Jupyter
#! Initially only groups of depth 1 are present in the graph. Left clicking on any vertex will then highlight that
#! vertex with a colour and the graph of depth 2 is shown, only the groups that project to the selected group will be
#! shown and their border will change to the colour that corresponds. Now clicking on more vertices will do the same
#! thing, reveal more vertices on the next depth and colour the borders correspondingly. Clicking on a selected vertex
#! will deselect it and hide the corresponding vertices on the graph for the next depth. If the graph becomes to small
#! to reasonably see you can use the scroll wheel to zoom and you can pan by holding down shift and using the mouse.
#! If selecting a vertex does not show the next graph make sure that the next depth is in the library.
#!
#! Square vertices are cyclic
#! Octagon vertices are nilpotent
#!
#! @Returns
#! A JupyterRenderableType that will run the app in Jupyter
#!
#! @Arguments k
DeclareGlobalFunction("RunApp@");

