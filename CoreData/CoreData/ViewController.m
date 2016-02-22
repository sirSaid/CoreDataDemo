

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Person.h"

@interface ViewController ()

/// 连接上下文属性
@property (nonatomic,strong) NSManagedObjectContext *context;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 误区:CoreData 是数据库
    /*
     CoreData 05年 iOS5之后发布,主要提供的是:ORM功能(对象-关系映射),CoreData在存储数据的时候可以采用以下四种方式:1:数据库方式;2:XML文件;3:二进制文件形式;4:内存的形式(5:自定义类型的形式---简单了解);默认是采用数据可以存储方式.
     CoreData 是苹果封装的一个工作在模型层的框架(优势:1:可以直接存储OC对象,也可以把OC对象直接从以上四种存储文件中取出;
     2:相对于数据库繁琐的sql语句,CoreData不用在写sql语句;)
     */
    
    // 数据持久化技术:plist文件;NSUserDefaults;数据库(sqlite);文件(XML,JSON,TXT等);CoreData
    
    // CoreData 里面一些重要的对象
   
    /* 1:NSManagedObjectContext :管理上下文,主要作用是:负责应用程序和数据库之间的交互(CoreData任何实际的操作都是通过它来完成)
       2:NSPersistentStoreCoordinator :连接器(桥梁/映射) 主要作用:决定CoreData存储的方式,并且连接到具体存储的位置;
       3:NSManagedObject :CoreData 存取的直接对象
       4:NSManagedObjectModel:模型实体类
    */
    
    // 1.创建一个NSManagedObjectModel对象(描述实体模型) 找到可视化文件实体类
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // 2.连接器
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 存储的路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSLog(@"%@",path);
    // 拼接路径
    path = [path stringByAppendingPathComponent:@"data"];
    
    // 链接路径
    // 第一个参数:存储的类型;第三个参数是路径;第四个参数是版本迭代的迁移
    // 版本迁移 第一个key值:自动迁移旧版本数据;
    // 第二个key值:自动匹配模型
    NSDictionary *dict = @{NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],
                           NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};
    NSError *error = nil;
    [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                   configuration:nil
                                             URL:[NSURL fileURLWithPath:path]
                                         options:dict
                                           error:&error];
    // 3.初始化管理上下文
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    // 上下文管理 连接器(可以直接操纵model 连接器 位置)
    self.context.persistentStoreCoordinator = storeCoordinator;
    
}

#pragma mark ----- 插入数据
- (IBAction)InsertDataBtnDidClicked:(id)sender
{
    NSInteger i = (arc4random()% 100);
    
    // NSEntityDescription 通过实体描述一个类
    Person *aPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
    
    // 通过KVC的方式去复制
    NSString *nameString = [NSString stringWithFormat:@"name:%ld",i];
//    [aPerson setValue:nameString forKey:@"name"];
    aPerson.name = nameString;
    NSNumber *ageNumber = [NSNumber numberWithInteger:i];
//    [aPerson setValue:ageNumber forKey:@"age"];
    aPerson.age = ageNumber;
    // 通过上面几部并没有真正的把aPerson保存到数据库,而是暂时保存到context里面
    // 如果上下文管理器 有改变 则进行保存
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}

#pragma mark ----- 搜索coredata存储的所有数据
- (IBAction)SearchAllDataBtnDidClicked:(id)sender
{
    // 创建搜索请求对象,并且指明所有的数据类型
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    
    NSArray *objcArray = [self.context executeFetchRequest:request error:nil];
     // 遍历数组
    for (Person *per in objcArray) {
        NSLog(@"%@ %@",per.name,per.age);
    }
}
#pragma mark ----- 按条件搜索
- (IBAction)SearchAgeBtnDidClicked:(id)sender
{
    // coreData 条件检索,是通过谓词的方式
    //创建请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    
    // 通过谓词去限定检索条件
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age > 70"];
    // 检索 name里面带0的 person
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like '*2*'"];
    
    // 把谓词条件 age > 70 赋值给需要检索的对象
    request.predicate = predicate;
    
    // 执行检索请求
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    
    // 遍历
    for (Person *per in array) {
        NSLog(@"%@ %@",per.name,per.age);
    }
}

#pragma mark -----  更新数据
- (IBAction)upDateDidClicked:(id)sender
{
    //需求: 把年龄大于65的person的name改为老头
    // 创建请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    // 谓词检索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age > 65"];
    // 把检索条件给请求对象
    request.predicate = predicate;
    
    // 执行检索
    NSArray *arr = [self.context executeFetchRequest:request error:nil];
    
    // 遍历
    for (Person *p in arr) {
        p.name = @"老头";
        NSLog(@"姓名:%@ 年龄:%@",p.name,p.age);
    }
    // 如果上下文管理器 有改变 则更新到数据库
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}
#pragma mark ----- 删除数据
- (IBAction)deleteBtnDidClicked:(id)sender
{
    // 需求:删除年龄<20 的person
    // 创建请求对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    // 创建谓词检索条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"age < 20"];
    // 把检索条件给请求对象
    request.predicate = predicate;
    // 执行检索
    NSArray *array = [self.context executeFetchRequest:request error:nil];
    // 删除
    
    if (array.count > 0) {
        for (Person *per in array) {
            // coreData 执行删除操作
            [self.context deleteObject:per];
            NSLog(@"删除成功");
        }
    }
    
    // 查看context是否有改变, 更新到数据库
    if ([self.context hasChanges]) {
        [self.context save:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
