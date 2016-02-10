//
//  WBWJContentViewController.swift
//  WhatToExpect
//
//  Created by Andrew McKinley on 1/13/16.
//
//

import UIKit

protocol WBWJContentDelegate{
    func didSelectRowWithIndex(_index:UInt)
}

class WBWJContentViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource , WBWJSlidingRightDelegate, WBWJSlidingLeftDelegate{

    @IBOutlet var journeyTableView: UITableView!
    
    var viewModel: WBWJViewModel?
    let wbwjStoryboard: UIStoryboard = UIStoryboard(name: kWBWJStoryboardName, bundle: nil)
    private let tracker:WBWJAnalyticsTracker = WBWJAnalyticsTracker()
    //************************************************************
    //MARK: UIViewController lifecycle
    //************************************************************
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.journeyTableView.rowHeight = UITableViewAutomaticDimension;
        self.journeyTableView.showsVerticalScrollIndicator = false
        let wbwPlaceholderNib = UINib(nibName: WBW_PLACEHOLDER_TABLEVIEWCELL_NIB, bundle: nil);
        self.journeyTableView.registerNib(wbwPlaceholderNib, forCellReuseIdentifier: WBW_TABLEVIEW_CELL_PLACEHOLDERVIEW_ID);
        self.journeyTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
    }
    
    //************************************************************
    //MARK: Data Organization and Retrevial
    //************************************************************
    
    //WBWJPageViewController should call this method when the data has arrived
    func updateContentWithModel(_model:WBWJViewModel!){
        if self.journeyTableView != nil {
            self.viewModel = _model
            self.journeyTableView.reloadData()
            self.view.setNeedsUpdateConstraints()
            
            self.journeyTableView.setNeedsLayout()
            self.journeyTableView.layoutIfNeeded()
            self.journeyTableView.reloadData()
            for section:WBWJBaseSection in _model.sections{
                if section.sectionType == .Amazon{
                    if let thisSection:WBWJSlidingSection = section as? WBWJSlidingSection{
                        if let views:[WBWJAmazonProductView] = thisSection.slidingViews as? [WBWJAmazonProductView]{
                            if views.count >= 1 {
                                if let productView:WBWJAmazonProductView = views.first{
                                    if let model = productView.productModel{
                                        self.tracker.trackPageLoad(forWeek: _model.weekNo, withAmazonModel: model)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else{
            print("error!!! page was released")
        }
        
    }
    
    private func setPlaceholderCell(indexPath indexPath:NSIndexPath, tableView: UITableView) -> WBWPlaceHolderTableViewCell {
        
        let wbwPlacehoderCell = tableView.dequeueReusableCellWithIdentifier(WBW_TABLEVIEW_CELL_PLACEHOLDERVIEW_ID) as! WBWPlaceHolderTableViewCell;
        
        wbwPlacehoderCell.backgroundColor = UIColor.clearColor();

        wbwPlacehoderCell.setPlaceholderContent("Retrieving content")
        if let _:WBWJViewModel = self.viewModel{
            wbwPlacehoderCell.backgroundGlowAnimationFromColor(startAnimation: true)
        }else{
            wbwPlacehoderCell.backgroundGlowAnimationFromColor(startAnimation: false)
        }
        
        return wbwPlacehoderCell;
        
    }


    // Tableview delegate methods
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let viewModel:WBWJViewModel = self.viewModel{
            return viewModel.sections.count
        } else{
            return 1
        }
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if let viewModel:WBWJViewModel = self.viewModel{
            let eachCell = viewModel.sections[indexPath.row]
            switch eachCell {
                case eachCell as WBWJRegularSection:
                    if let isLeft:Bool = eachCell.isLeft{
                        if isLeft == true {
                            if let cell:WBWJLeftTableViewCell = tableView.dequeueReusableCellWithIdentifier(kWBWJLeftCellId, forIndexPath: indexPath) as? WBWJLeftTableViewCell{
                                if let data:WBWJRegularSection = eachCell as? WBWJRegularSection{
                                    cell.updateWithModel(data)
                                }
                                
                                return cell
                            }
                        } else {
                            if let cell:WBWJRightTableViewCell = tableView.dequeueReusableCellWithIdentifier(kWBWJRightCellId, forIndexPath: indexPath) as? WBWJRightTableViewCell{
                                if let data:WBWJRegularSection = eachCell as? WBWJRegularSection{
                                    cell.updateWithModel(data)
                                }
                                
                                return cell
                            }
                        }
                    }

                case eachCell as WBWJAdSection:
                    if let cell:WBWJSimpleTableViewCell = tableView.dequeueReusableCellWithIdentifier(kWBWJSimpleCellId, forIndexPath: indexPath) as? WBWJSimpleTableViewCell{
                        if let cellData:WBWJAdSection = eachCell as? WBWJAdSection{
                            cell.updateWithModel(cellData)
                        }
                        return cell
                    }
                    break
                case eachCell as WBWJSlidingSection:
                    if let isLeft:Bool = eachCell.isLeft{
                        if isLeft == true {
                            if let cell:WBWJSlidingLeftTableViewCell = tableView.dequeueReusableCellWithIdentifier(kWBWJSlidingLeftCellId, forIndexPath: indexPath) as? WBWJSlidingLeftTableViewCell{
                                if let cellData:WBWJSlidingSection = eachCell as? WBWJSlidingSection{
                                    cell.updateWithModel(cellData)
                                    cell.delegate = self
                                }
                                return cell
                            }
                        } else {
                            if let cell:WBWJSlidingRightTableViewCell = tableView.dequeueReusableCellWithIdentifier(kWBWJSlidingRightCellId, forIndexPath: indexPath) as? WBWJSlidingRightTableViewCell{
                                if let cellData:WBWJSlidingSection = eachCell as? WBWJSlidingSection{
                                    cell.updateWithModel(cellData)
                                    cell.delegate = self
                                }
                                return cell
                            }
                        }
                    }
                    
                    break
                default:
                    print("error incorrect data")
                    return self.setPlaceholderCell(indexPath: indexPath, tableView: tableView);
                }

        } else{
            //defaultCell
            return self.setPlaceholderCell(indexPath: indexPath, tableView: tableView);
        }

        print("error incorrect data")
        return self.setPlaceholderCell(indexPath: indexPath, tableView: tableView);
    }
    
    
    internal func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let viewModel:WBWJViewModel = self.viewModel{
            let _section:WBWJBaseSection = viewModel.sections[indexPath.row]
            switch _section.sectionType as WBWJSectionType {
            case  .YourBaby, .Video, .NativeAd, .YourBody, .CommonSymptoms, .AskYourDoctor:
                
                    if let babyDetail:WBWJRegularSection = _section as? WBWJRegularSection{
                        if babyDetail.isLastCell == true {
                            return 65
                        } else {
                            return 160
                        }
                    }
                break
            case  .Amazon, .RecommendedReadings:
                
                if let babyDetail:WBWJSlidingSection = _section as? WBWJSlidingSection{
                    if babyDetail.isLastCell == true {
                        return 224
                    } else {
                        return 310
                    }
                }
                
                break
                
            default:
                return UITableViewAutomaticDimension
    
            }
        }
        return UITableViewAutomaticDimension
    }

    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if let viewModel:WBWJViewModel = self.viewModel{
            let _section:WBWJBaseSection = viewModel.sections[indexPath.row]
            switch _section.sectionType as WBWJSectionType {
                case  .YourBaby:
                    if let vc:WBWJYourBabyViewController = self.wbwjStoryboard.instantiateViewControllerWithIdentifier(kWBWJYourBabyViewControllerID) as? WBWJYourBabyViewController{
                        
                        if let babyDetail:WBWJRegularSection = _section as? WBWJRegularSection{
                            if let data:WBWJYourBabyDetail = babyDetail.detailDataObject as? WBWJYourBabyDetail{
                                vc.updateData(data)
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)

                    }

                    break
                case  .Video:
                    if let playlist:[EHVideoModel] = viewModel.videoPlaylistArray{
                        let pregnancyWeek = WBWHelper.validateWeek(viewModel.weekNo)
                        
                        let playerVC:EHFullScreenVideoVC = EHFullScreenVideoVC.init(withVideoPlaylist: playlist, andWeek: pregnancyWeek)
                        let nav:LandscapeLockedNavController = LandscapeLockedNavController.init(rootViewController: playerVC)
                        self.presentViewController(nav, animated: false, completion: nil)
                    }
                    

                    break
                case  .YourBody:
                    if let vc:WBWJYourBodyViewController = self.wbwjStoryboard.instantiateViewControllerWithIdentifier(kWBWJYourBodyViewControllerID) as? WBWJYourBodyViewController{
                        
                        if let babyDetail:WBWJRegularSection = _section as? WBWJRegularSection{
                            if let data:WBWJYourBodyDetail = babyDetail.detailDataObject as? WBWJYourBodyDetail{
                                vc.updateData(data)
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)

                    }
                    break

                case  .CommonSymptoms:
                    if let vc:WBWJSymptomsViewController = self.wbwjStoryboard.instantiateViewControllerWithIdentifier(kWBWJSymptomsViewControllerID) as? WBWJSymptomsViewController{
                        
                        if let babyDetail:WBWJRegularSection = _section as? WBWJRegularSection{
                            if let data:WBWJSymptomsLookupDetail = babyDetail.detailDataObject as? WBWJSymptomsLookupDetail{
                                vc.updateData(data)
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    break
                    
                case  .AskYourDoctor:
                    if let vc:WBWJAskYourDocViewController = self.wbwjStoryboard.instantiateViewControllerWithIdentifier(kWBWJAskYourDoctorViewControllerID) as? WBWJAskYourDocViewController{
                        
                        if let babyDetail:WBWJRegularSection = _section as? WBWJRegularSection{
                            if let data:WBWJAskYourDoctorDetail = babyDetail.detailDataObject as? WBWJAskYourDoctorDetail{
                                vc.updateData(data)
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }

                    break

                default:
                    print("error no data!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    break
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let viewModel:WBWJViewModel = self.viewModel{
            let _section:WBWJBaseSection = viewModel.sections[indexPath.row]
            if _section.sectionType == .Amazon{
                if let regSection:WBWJSlidingSection = _section as? WBWJSlidingSection{
                    if let amazonViews:[WBWJAmazonProductView] = regSection.slidingViews as? [WBWJAmazonProductView]{
                        if let firstView:WBWJAmazonProductView = amazonViews.first{
                            self.tracker.trackAmazonSummaryView(firstView.productModel)
                        }
                    }
                }
            } else if _section.sectionType == .NativeAd{
                if let regSection:WBWJAdSection = _section as? WBWJAdSection{
                    if let cell:WBWJSimpleTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as? WBWJSimpleTableViewCell{
                        cell.trackDFPAdViewImpression(regSection.adModel!)
                    }
                }
            }
        }
        /*
        
        // Track Partner Product Impression
        if let _: WBWContentPartnerProduct = contentData.1 as? WBWContentPartnerProduct{
            for section:WBWBaseSection in (self.viewModel?.sections)! {
                if section.sectionType == WBWSectionType.Amazon {
                    if let partnerSection:WBWPartnerProductSection = section as? WBWPartnerProductSection{
                        
                    }
                    
                }
            }
        }*/
        
    }
    
    func didSelectIndex(_index:UInt, ofCell cell:UITableViewCell){
        if let indexPath:NSIndexPath = self.journeyTableView.indexPathForCell(cell){
            if let viewModel:WBWJViewModel = self.viewModel{
                let _section:WBWJBaseSection = viewModel.sections[indexPath.row]
                if let _sectionData:WBWJSlidingSection = _section as? WBWJSlidingSection {
                    if let views:[WBWJAmazonProductView] = _sectionData.slidingViews as? [WBWJAmazonProductView]{
                        if UInt(views.count) > _index{
                            let selectedProduct  = views[Int(_index)]
                            EHTracking.logWebPageView(selectedProduct.contentUrl?.path)
                            if let url:NSURL = selectedProduct.contentUrl{
                                UIApplication.sharedApplication().openURL(url)
                            WBWJAnalyticsTracker.trackTappedOnAmazonProduct(selectedProduct.productModel, _product: selectedProduct.product, _index: Int(_index))
                            }
                        }
                    } else if let views:[WBWJRecommendedReadingView] = _sectionData.slidingViews as? [WBWJRecommendedReadingView]{
                        if UInt(views.count) > _index{
                            let selectedProduct  = views[Int(_index)]
                            EHTracking.logWebPageView(selectedProduct.contentUrl?.path)
                            let webViewController : EHWebModalViewController = EHWebModalViewController.init(URL: selectedProduct.contentUrl)
                            
                            self.presentViewController(webViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
