# slepian_bgetraer

This directory contains MATLAB functions and scripts complementing the slepian_alpha, bravo, etc suite fount at https://github.com/csdms-contrib modified and written by bgetraer@princeton.edu, FALL 2017-SPRING 2019

Common problems I ran into with very very simple solutions:
	
1	Function continues to fail, asking for some file or directory you do not have. Make the directory folder being requested, find the requested file from http://geoweb.princeton.edu/people/simons/software.html and put it where it belongs.
2	Slepian bases are not plotting where you expect them to. Some functions use latitude, some use co-latitude, and you are mixing them up.

SCRIPTS FOR JP02 (spring semester JP on analyzing Greenland ice through wavelet decomposition of GRACE data) ARE SEQUENTIAL FOLLOWS:

1) BOXGREENLAND.m
2) IMAGERYSEQ.m
3) CHOOSEWAVELET.m
4) ANALYZEWAVELET.m
5) WAVEINPOLY.m