//
//  FCSmallImageViewController.m
//  PhotoCatchTest
//
//  Created by pg on 2016/11/19.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "FCSmallImageViewController.h"
#import "PhotoImageCell.h"
#import "FCPhotoManager.h"
#import "FCBigImageViewController.h"

#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height

@interface FCSmallImageViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray<PHAsset*> *allImageArr;
}
@property (nonatomic,strong)UICollectionView *myCollectionView;

@property (nonatomic,strong)NSMutableArray *selectedImageArr;

@property (nonatomic,strong)UILabel *numLabel;
@end

@implementation FCSmallImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMyImageListUI];
    
}

-(void)initMyImageListUI{
    
    //获取所有的照片
    allImageArr = [FCPhotoManager getAssetsInAssetCollection:[FCPhotoManager getSpecialAlbumWithType:1].assetCollection ascending:YES];
    _selectedImageArr = [NSMutableArray array];
    
    // 设置流水布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    // 定义大小
    CGFloat collectionW = ([UIScreen mainScreen].bounds.size.width-10)/4.0;
    layout.itemSize = CGSizeMake(collectionW, collectionW);
    // 设置最小行间距
    layout.minimumLineSpacing = 2;
    // 设置垂直间距
    layout.minimumInteritemSpacing = 2;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    // 设置滚动方向（默认垂直滚动）
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-30) collectionViewLayout:layout];
    _myCollectionView.backgroundColor = [UIColor whiteColor];
    _myCollectionView.delegate = self;
    _myCollectionView.dataSource = self;
    [self.view addSubview:_myCollectionView];
#pragma mark -注册两个相同的cell加上注释
    [self.myCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoImageCell class]) bundle:nil] forCellWithReuseIdentifier:@"MarkCollectionCell"];
    [self.myCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PhotoImageCell class]) bundle:nil] forCellWithReuseIdentifier:@"cameraCell"];
    //添加底部的View
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, KScreenH -30, KScreenW, 30)];
    bottomView.backgroundColor = [UIColor whiteColor];
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(KScreenW-55, 0, 40, 30)];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor colorWithRed:0 green:80/255.0 blue:225/255.0 alpha:1] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmBtn addTarget:self action:@selector(confirmMyChoose) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:confirmBtn];
    
    //添加的数量
    UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, KScreenW-120, 30)];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.font = [UIFont systemFontOfSize:14];
    numLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    numLabel.text = [NSString stringWithFormat:@"0/%zd",_maxSelect];
    _numLabel = numLabel;
    [bottomView addSubview:numLabel];
    [self.view addSubview:bottomView];
}
#pragma mark - 确定选定的图片
-(void)confirmMyChoose{
    if (_returnBlock) {
        _returnBlock(_selectedImageArr);
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return allImageArr.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row) {
        PhotoImageCell *cell = [PhotoImageCell cellWithCollectionView:collectionView WithIndexPath:indexPath];
        //初始化所有的按钮的状态
        cell.selectedBtn.selected = NO;
        cell.selectedBtn.tag = indexPath.row;
        [cell.selectedBtn addTarget:self action:@selector(smallImageSelectClickAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.assetModel = allImageArr[indexPath.row-1];
        [_selectedImageArr enumerateObjectsUsingBlock:^(FCPhotoModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.imageName isEqualToString:[allImageArr[indexPath.row-1] valueForKey:@"filename"]]) {
                cell.selectedBtn.selected = YES;
            }
        }];
        return cell;
    }else{
        PhotoImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cameraCell" forIndexPath:indexPath];
        cell.selectedBtn.hidden = YES;
        return cell;
    }
    return nil;
}

#pragma mark -选择图片的操作
-(void)smallImageSelectClickAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {//添加进数组
        if (self.maxSelect == _selectedImageArr.count) {
            //已达到最大选择值
            NSLog(@"已达到最大值");
            sender.selected = NO;
        }else{
            //添加到数组中
            FCPhotoModel *model = [[FCPhotoModel alloc]init];
            model.asset =  allImageArr[sender.tag-1];
            model.imageName = [allImageArr[sender.tag-1] valueForKey:@"filename"];
            [_selectedImageArr addObject:model];
        }
    }else{//从数组中删除
        [_selectedImageArr enumerateObjectsUsingBlock:^(FCPhotoModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.imageName isEqualToString:[allImageArr[sender.tag-1] valueForKey:@"filename"]]) {
                *stop = YES;
                if (*stop == YES) {
                    [_selectedImageArr removeObject:obj];
                }
            }
        }];
    }
    _numLabel.text = [NSString stringWithFormat:@"%zd/%zd",_selectedImageArr.count,_maxSelect];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row) {
        __weak typeof(self) weakSelf = self;
        FCBigImageViewController *bigVC = [[FCBigImageViewController alloc]init];
        bigVC.currentIndex = indexPath.row -1;
        bigVC.allImageListArr = allImageArr;
        bigVC.selectImageArr = _selectedImageArr;
        bigVC.maxCount = self.maxSelect;
        bigVC.imageReturnlock = ^(NSArray *returnArr){
            _selectedImageArr = [NSMutableArray arrayWithArray:returnArr];
             _numLabel.text = [NSString stringWithFormat:@"%zd/%zd",_selectedImageArr.count,_maxSelect];
            //再刷新界面
            [weakSelf.myCollectionView reloadData];
        };
        [self.navigationController pushViewController:bigVC animated:YES];        
    }
}


@end
