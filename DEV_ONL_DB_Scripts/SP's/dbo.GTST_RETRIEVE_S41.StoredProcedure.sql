/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S41]  
(  
     @An_Case_IDNO                            NUMERIC(6) ,  
     @An_MemberMci_IDNO                       NUMERIC(10),  
     @An_Schedule_NUMB                        NUMERIC(10) ,  
     @Ad_Test_DATE                            DATE   OUTPUT,  
     @Ac_TypeTest_CODE                        CHAR(1) OUTPUT ,
     @An_OthpLocation_IDNO					 NUMERIC(9) OUTPUT, 
     @As_Lab_NAME							 VARCHAR(60) OUTPUT, 
     @Ac_LocationState_CODE					 CHAR(2) OUTPUT, 
     @An_CountyLocation_IDNO				 NUMERIC(3) OUTPUT
 )  
AS  
  
/*  
 *  PROCEDURE NAME    : GTST_RETRIEVE_S41
 *  DESCRIPTION       : This sp will Test Date and Test Type of member for particular case id. 
 *  DEVELOPED BY      : IMP Team  
 *  DEVELOPED ON      : 02-AUG-2011  
 *  MODIFIED BY       :   
 *  MODIFIED ON       :   
 *  VERSION NO        : 1  
*/  
  
   BEGIN  
  
      DECLARE  
         @Lc_TestResultCancel_CODE           CHAR(1) = 'C',  
         @Lc_TestResultFailedToAppear_CODE   CHAR(1) = 'F',
         @Lc_TestResultInclusion_CODE        CHAR(1) ='I',  
         @Ld_High_DATE                       DATE    = '12/31/9999';  
           
       SELECT TOP 1 @Ad_Test_DATE     = Test_Date,  
			  @Ac_TypeTest_CODE = TypeTest_CODE  ,
			  @An_OthpLocation_IDNO  =  OthpLocation_IDNO ,
			  @As_Lab_NAME           = Lab_NAME      ,
			  @Ac_LocationState_CODE  =LocationState_CODE ,
			  @An_CountyLocation_IDNO  =CountyLocation_IDNO     
				FROM GTST_Y1 g  
				WHERE g.Case_IDNO    = @An_Case_IDNO  
				AND g.MemberMci_IDNO =@An_MemberMci_IDNO  
				AND g.Schedule_NUMB != @An_Schedule_NUMB  
				AND g.EndValidity_DATE=@Ld_High_DATE  
				AND g.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailedToAppear_CODE,@Lc_TestResultInclusion_CODE)  
				AND g.Test_DATE=(SELECT MAX(Test_DATE)   
										FROM GTST_Y1 s  
										WHERE s.Case_IDNO   =@An_Case_IDNO   
										AND s.schedule_NUMB !=@An_Schedule_NUMB  
										AND s.MemberMci_IDNO=g.MemberMci_IDNO  
										AND s.EndValidity_DATE = @Ld_High_DATE  
										AND s.TestResult_CODE NOT IN (@Lc_TestResultCancel_CODE,@Lc_TestResultFailedToAppear_CODE,@Lc_TestResultInclusion_CODE));  
          
END  -- END of GTST_RETRIEVE_S41


GO
