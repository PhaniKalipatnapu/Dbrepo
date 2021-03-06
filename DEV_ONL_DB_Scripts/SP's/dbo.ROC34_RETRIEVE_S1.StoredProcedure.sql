/****** Object:  StoredProcedure [dbo].[ROC34_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[ROC34_RETRIEVE_S1]( 
			@Ad_BeginQtr_DATE				DATE,
			@Ad_EndQtr_DATE					DATE, 
			@Ac_TypeReport_CODE             CHAR(1)  
			 )			
AS  
  
/*  
 *     PROCEDURE NAME    : ROC34_RETRIEVE_S1   
 *     DESCRIPTION       : This procedure is used to show the quarterly details for OCSE34A Report  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 15-NOV-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
 */  
 
    BEGIN            		
			SELECT  r.Line1_AMNT,
					r.Line2a_AMNT,
					r.Line2b_AMNT,
					r.Line2c_AMNT,
					r.Line2d_AMNT,
					r.Line2e_AMNT,
					r.Line2f_AMNT,
					r.Line2h_AMNT,
					r.Line2g_AMNT,
					r.Line3_AMNT,
					r.Line4a_AMNT,
					r.Line4ba_AMNT,
					r.Line4bb_AMNT,
					r.Line4bc_AMNT,
					r.Line4bd_AMNT,
					r.Line4be_AMNT,
					r.Line4bf_AMNT,
					r.Line4c_AMNT,
					r.Line5_AMNT,
					r.Line7aa_AMNT,
					r.Line7ac_AMNT,
					r.Line7ba_AMNT,
					r.Line7bb_AMNT,
					r.Line7bc_AMNT,
					r.Line7bd_AMNT,
					r.Line7ca_AMNT,
					r.Line7cb_AMNT,
					r.Line7cc_AMNT,
					r.Line7cd_AMNT,
					r.Line7ce_AMNT,
					r.Line7cf_AMNT,
					r.Line7da_AMNT,
					r.Line7db_AMNT,
					r.Line7dc_AMNT,
					r.Line7dd_AMNT,
					r.Line7de_AMNT,
					r.Line7df_AMNT,
					r.Line7ee_AMNT,
					r.Line7ef_AMNT,
					r.Line9a_AMNT,
					r.Line9b_AMNT,
					r.Line11_AMNT,
					r.Line3P2_AMNT,
					r.Line4P2_AMNT,
					r.Line5P2_AMNT,
					r.Line6P2_AMNT,
					r.Line7P2_AMNT,
					r.Line9P2_AMNT,
					r.Line10P2_AMNT,
					r.Line11P2_AMNT,
					r.Line12P2_AMNT,
					r.Line13P2_AMNT,
					r.Line14P2_AMNT,
					r.Line15P2_AMNT,
					r.Line16P2_AMNT,
					r.Line17P2_AMNT,
					r.Line18P2_AMNT,
					r.Line19P2_AMNT,
					r.Line20P2_AMNT,
					@Ad_BeginQtr_DATE AS  BeginQtr_DATE,
					@Ad_EndQtr_DATE	  AS  EndQtr_DATE 		 
             FROM  ROC34_Y1 r
             WHERE  r.BeginQtr_DATE	= @Ad_BeginQtr_DATE
               AND  r.EndQtr_DATE		= @Ad_EndQtr_DATE
               AND  r.TypeReport_CODE	= @Ac_TypeReport_CODE;

END; -- END OF ROC34_RETRIEVE_S1


GO
