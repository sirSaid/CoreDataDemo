# CoreDataDemo
自行创建CoreData，介绍起原理及存储机制
误区:CoreData 是数据库
    
     CoreData 05年 iOS5之后发布,主要提供的是:ORM功能(对象-关系映射),CoreData在存储数据的时候可以采用以下四种方式:
     1:数据库方式;
     2:XML文件;
     3:二进制文件形式;
     4:内存的形式(5:自定义类型的形式---简单了解);默认是采用数据可以存储方式.
     CoreData 是苹果封装的一个工作在模型层的框架(优势:1:可以直接存储OC对象,也可以把OC对象直接从以上四种存储文件中取出;
     2:相对于数据库繁琐的sql语句,CoreData不用在写sql语句;)
     
    
    
     CoreData 里面一些重要的对象
   
       1:NSManagedObjectContext :管理上下文,主要作用是:负责应用程序和数据库之间的交互(CoreData任何实际的操作都是通过它来完成)
       2:NSPersistentStoreCoordinator :连接器(桥梁/映射) 主要作用:决定CoreData存储的方式,并且连接到具体存储的位置;
       3:NSManagedObject :CoreData 存取的直接对象
       4:NSManagedObjectModel:模型实体类
