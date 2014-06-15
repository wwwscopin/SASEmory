proc glm  data=glnd.basedemo;
  class center;
  model apachese=center;
  means center / tukey;
 where center <5;
run;
