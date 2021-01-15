//
//  AudiCar.h
//  csvExplan
//
//  Created by Star J on 2021/1/5.
//  Copyright © 2021 Star J. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface AudiCar : NSObject

@property (nonatomic , assign)NSInteger year;//年份

@property (nonatomic , assign)BOOL trasmission;//变速箱是否手动

@property (nonatomic , assign)NSInteger mileage;//英里数

@property (nonatomic , assign)NSInteger engineSize;//排量

@property (nonatomic , assign)NSInteger price;//排量

@property (nonatomic , assign)double consumValue;

@property (nonatomic , strong)NSString *Type;


@end

NS_ASSUME_NONNULL_END
