

# 一、部署流程文件，影响4张表

+ **系统属性表**

  > SELECT * FROM ACT_RE_PROCDEF;

+  **资源表(流程图资源附件)**

  > SELECT * FROM ACT_GE_BYTEARRAY;

+  **流程部署对象表**

  > SELECT * FROM ACT_RE_DEPLOYMENT;

+ **流程定义表**

  > SELECT * FROM ACT_RE_PROCDEF;

# 二、启动流程 影响7张表

+ 执行对象表

  > Select * from ACT_RU_EXECUTION

+ 流程实例历史表

  > Select * from	ACT_HI_PROCINST

+ 当前正在执行任务

  > SELECT * FROM ACT_RU_TASK

+ 历史任务表

  > SELECT * FROM ACT_HI_TASKINST

+ 历史活动表

  > SELECT * FROM ACT_HI_ACTINST

+ 当前任务执行人表

  > SELECT * FROM ACT_RU_IDENTITYLINK

+ 历史任务执行人表

  > SELECT * FROM ACT_HI_IDENTITYLINK

# 三、流程变量 ,影响2张表 

