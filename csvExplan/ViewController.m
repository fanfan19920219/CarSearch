//
//  ViewController.m
//  csvExplan
//
//  Created by Star J on 2021/1/5.
//  Copyright © 2021 Star J. All rights reserved.
//

#import "ViewController.h"
#import "AudiCar.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *guideLabel;//展示查找状态
@property (nonatomic, strong)UITableView *tableView;//展示查找结果
@property (nonatomic, strong)NSMutableArray *dataSource;//数据源
@property (nonatomic, strong)NSMutableArray *current_dataSource;//当前计算过查找结果的数据源
@property (strong, nonatomic) IBOutlet UITextField *year;//用户输入框 年
@property (strong, nonatomic) IBOutlet UITextField *price;//用户输入框 价格
@property (strong, nonatomic) IBOutlet UITextField *mile;//用户输入框 里程
@property (weak, nonatomic) IBOutlet UIButton *addCar;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray new];
    self.current_dataSource = [NSMutableArray new];
    
    [self explane];
}



- (IBAction)addCar:(UIButton *)sender {
    
    NSLog(@"current Car");
    
    
}


-(IBAction)funcGuide:(UIButton*)sender{
    
    
    double year = [self.year.text doubleValue];
    
    double price = [self.price.text doubleValue];
    
    double mile = [self.mile.text doubleValue];
    
    self.current_dataSource = [self.dataSource mutableCopy];
    
    self.guideLabel.hidden = NO;
    
    
    //开启异步线程
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //遍历数据源
        for(AudiCar *model in self.current_dataSource){
            
            //计算数据源的推荐值
            model.consumValue = [self func:year :price :mile withModel:model];
            
        }
        
        
        //进行推荐值的排序
        NSComparator cmptr = ^(AudiCar *obj1, AudiCar *obj2){
            if (obj1.consumValue < obj2.consumValue) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (obj1.consumValue > obj2.consumValue) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        
        //得到的结果
        NSArray *sorArray = [self.current_dataSource sortedArrayUsingComparator:cmptr];
        
        
        //把得到的结果截取前300 进行排序
        self.current_dataSource = [[sorArray  subarrayWithRange:NSMakeRange(0, 300)] mutableCopy];
        
        //回到主线程 把得到的数据进行展示到页面上
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            self.guideLabel.hidden = YES;
        });
        
    });
    
}


/**
 核心算法 满分权重100分
 年份权重 25分
 价格权重 40分
 公里权重 35分
 
 最终权重的权重 =  100  - 年份的绝对值差/20 *年份权重 - 价格绝对值差/期望价格*价格权重 - 里程数绝对值差/期望里程数 * 里程权重
 
 然后按照这个已经计算好的权重进行排序
 
 */


-(double)func:(double)year :(double)price :(double)mile withModel:(AudiCar*)model{
    
    double returnValue = 100 - ((fabs( model.year - year ) /20.f )*25.f  + 35.f*(fabs( mile - model.mileage )/mile) + + fabs((double)(price - model.price)/price)*40.f);
    return returnValue;
    
}




-(void)creatableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, self.view.frame.size.height - 350) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    NSLog(@"111");
    NSLog(@"111");
    NSLog(@"111");NSLog(@"111");
    NSLog(@"111");NSLog(@"111");
    NSLog(@"111");NSLog(@"111");


    
}



-(void)explane{
    NSMutableArray *array = [NSMutableArray array];
    NSString *filepath=[[NSBundle mainBundle] pathForResource:@"audi" ofType:@"csv"];
    FILE *fp = fopen([filepath UTF8String], "r");
    if (fp) {
        char buf[BUFSIZ];
        fgets(buf, BUFSIZ, fp);
        NSString *a = [[NSString alloc] initWithUTF8String:(const char *)buf];
        NSString *aa = [a stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        aa = [aa stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        //1
        //获取的是表头的字段
        NSArray *b = [aa componentsSeparatedByString:@","];
        
        while (!feof(fp)) {
            char buff[BUFSIZ];
            fgets(buff, BUFSIZ, fp);
            //获取的是内容
            NSString *s = [[NSString alloc] initWithUTF8String:(const char *)buff];
            NSString *ss = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            ss = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            NSArray *a = [ss componentsSeparatedByString:@","];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (int i = 0; i < b.count ; i ++) {
                //组成字典数组
                dic[b[i]] = a[i];
            }
            /*
             engineSize = "3.0";
             fuelType = Diesel;
             mileage = 62748;
             model = " A6";
             mpg = "53.3";
             price = 17500;
             tax = 150;
             transmission = Automatic;
             year = 2015;
             */
            AudiCar *car = [[AudiCar alloc]init];
            car.year = [dic[@"year"] intValue];
            car.trasmission = [[NSString stringWithFormat:@"%@",dic[@"transmission"]] isEqualToString:@"Automatic"];
            car.mileage = [dic[@"mileage"] intValue];
            car.price  = [dic[@"price"] intValue]*8.76;
            car.Type  = [NSString stringWithFormat:@"Audi%@",dic[@"model"]];
            [array addObject:car];
        }
    }
    self.current_dataSource = [array mutableCopy];
    self.dataSource = [array  mutableCopy];
    [self creatableView];
    NSLog(@"汽车数组加载完成了，一共有【%ld】辆汽车",array.count);
    NSLog(@"汽车数组加载完成了，一共有【%ld】辆汽车",array.count);
    
    NSLog(@"汽车数组加载完成了，一共有【%ld】辆汽车",array.count);
    NSLog(@"汽车数组加载完成了，一共有【%ld】辆汽车",array.count);
    //master
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.current_dataSource.count;
    NSLog(@"22");
    NSLog(@"22");
    NSLog(@"22");
    NSLog(@"22");
    NSLog(@"22");
    //master1
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellTag = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTag];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTag];
    }
    if(indexPath.row<=2){
        cell.textLabel.textColor = UIColor.redColor;
    }else{
        cell.textLabel.textColor = UIColor.blackColor;
    }
    
    AudiCar *model = self.current_dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@ %ld年  %ld元 %ldkm (%.2f) ",indexPath.row+1,model.Type,model.year,model.price,model.mileage,model.consumValue];
    return cell;
    
    
}

@end

