/****** Object:  StoredProcedure [dbo].[NRRQ_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[NRRQ_RETRIEVE_S2] (  
 @Ac_Notice_ID    CHAR(8),  
 @An_Case_IDNO    NUMERIC(6),  
 @Ac_Recipient_ID CHAR(10),  
 @Ac_File_ID      CHAR(15),  
 @Ad_From_DATE    DATE,  
 @Ad_To_DATE      DATE,  
 @Ai_RowFrom_NUMB INT=1,  
 @Ai_RowTo_NUMB   INT=10  
 )  
AS  
 /*    
 *     PROCEDURE NAME    : NRRQ_RETRIEVE_S2    
 *     DESCRIPTION       : Retrieve Notice Reprint Request details for a Case.  
 *     DEVELOPED BY      : IMP Team   
 *     DEVELOPED ON      : 03-AUG-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */  
 BEGIN  
  DECLARE @Li_Zero_NUMB			SMALLINT	=	0,  
          @Li_One_NUMB			SMALLINT	=	1,  
          @Lc_Empty_Text		CHAR(1)		=	'',
		  @Lc_Notice_ID_CSI13	CHAR(8)		=	'CSI-13',
		  @Ld_High_DATE			DATE		=	'12/31/9999';
          
 SELECT  N.Notice_ID,  
         N.Case_IDNO,  
    	 N.Recipient_ID,  
         N.Barcode_NUMB,  
         N.TransactionEventSeq_NUMB,  
         N.Generate_DTTM,  
         N.Recipient_CODE,  
         N.DescriptionNotice_TEXT,  
         N.WorkerRequest_ID,  
         N.TypeService_CODE,  
         N.File_ID,  
         N.StatusNotice_CODE,  
         N.RowCount_NUMB,  
         N.LoginWrkOficAttn_ADDR,  
         N.LoginWorkersOffice_NAME,  
         N.LoginWrkOficLine1_ADDR,  
         N.LoginWrkOficLine2_ADDR,  
         N.LoginWrkOficCity_ADDR,  
         N.LoginWrkOficState_ADDR,  
         N.LoginWrkOficZip_ADDR,  
         N.LoginWorkerOfficeCountry_ADDR,  
         N.RecipientAttn_ADDR,  
         N.Recipient_NAME,  
         N.RecipientLine1_ADDR,  
         N.RecipientLine2_ADDR,  
         N.RecipientCity_ADDR,  
         N.RecipientState_ADDR,  
         N.RecipientZip_ADDR,  
         N.RecipientCountry_ADDR  
         FROM (SELECT H.Notice_ID,  
    	    		  H.Case_IDNO,  
         			  H.Recipient_ID,  
         			  H.Barcode_NUMB,  
         			  H.TransactionEventSeq_NUMB,  
         			  H.Generate_DTTM,  
         			  H.Recipient_CODE,  
         			  (SELECT N2.DescriptionNotice_TEXT  
            		 	 FROM NREF_Y1 N2  
           			 	 WHERE N2.Notice_ID = H.Notice_ID  
            		 	 AND N2.EndValidity_DATE = @Ld_High_DATE) DescriptionNotice_TEXT,  
         		     H.WorkerRequest_ID,  
         		     H.TypeService_CODE,  
         		     H.File_ID,  
         		     H.StatusNotice_CODE,  
         		     H.RowCount_NUMB,
         		     ROW_NUMBER() OVER ( ORDER BY H.Generate_DTTM DESC ) AS Row_NUMB,  
         		     H.LoginWrkOficAttn_ADDR,  
         		     H.LoginWorkersOffice_NAME,  
         		     H.LoginWrkOficLine1_ADDR,  
         		     H.LoginWrkOficLine2_ADDR,  
         		     H.LoginWrkOficCity_ADDR,  
         		     H.LoginWrkOficState_ADDR,  
         		     H.LoginWrkOficZip_ADDR,  
         		     H.LoginWorkerOfficeCountry_ADDR,  
         		     H.RecipientAttn_ADDR,  
         		     H.Recipient_NAME,  
         		     H.RecipientLine1_ADDR,  
         		     H.RecipientLine2_ADDR,  
         		     H.RecipientCity_ADDR,  
         		     H.RecipientState_ADDR,  
         		     H.RecipientZip_ADDR,  
         		     H.RecipientCountry_ADDR  
    			FROM (SELECT N1.TransactionEventSeq_NUMB,  
                 		N1.Generate_DTTM,  
                 		N1.Notice_ID,  
                 		N1.Recipient_CODE,  
                 		N1.Case_IDNO,  
                 		N1.Recipient_ID,  
                 		N1.WorkerRequest_ID,  
                 		N1.TypeService_CODE,  
                 		C1.File_ID,  
                 		N1.StatusNotice_CODE,  
                 		N1.Barcode_NUMB,  
                 		COUNT(1) OVER() AS RowCount_NUMB,  
                 		ROW_NUMBER() OVER ( ORDER BY N1.Generate_DTTM DESC ) AS Row_NUMB,  
                 		N1.LoginWrkOficAttn_ADDR,  
                 		N1.LoginWorkersOffice_NAME,  
                 		N1.LoginWrkOficLine1_ADDR,  
                 		N1.LoginWrkOficLine2_ADDR,  
                 		N1.LoginWrkOficCity_ADDR,  
                 		N1.LoginWrkOficState_ADDR,  
                 		N1.LoginWrkOficZip_ADDR,  
                 		N1.LoginWorkerOfficeCountry_ADDR,  
                 		N1.RecipientAttn_ADDR,  
                 		N1.Recipient_NAME,  
                 		N1.RecipientLine1_ADDR,  
                 		N1.RecipientLine2_ADDR,  
                 		N1.RecipientCity_ADDR,  
                 		N1.RecipientState_ADDR,  
                 		N1.RecipientZip_ADDR,  
                 		N1.RecipientCountry_ADDR  
            				FROM NRRQ_Y1 N1    
                 			JOIN CASE_Y1 C1    
                  			ON N1.Case_IDNO = C1.Case_IDNO    
           					WHERE N1.Generate_DTTM BETWEEN @Ad_From_DATE AND DATEADD (DD, @Li_One_NUMB, @Ad_To_DATE)    
             				AND N1.Case_IDNO=ISNULL(@An_Case_IDNO,N1.Case_IDNO)    
             				AND C1.File_ID = ISNULL (@Ac_File_ID, C1.File_ID)    
             				AND N1.Notice_ID = ISNULL (@Ac_Notice_ID, N1.Notice_ID)    
             				AND N1.Recipient_ID = ISNULL(@Ac_Recipient_ID, Recipient_ID)  
             				AND EXISTS (SELECT 1  
         						  FROM FORM_Y1 FO  
        						  WHERE FO.Barcode_NUMB = N1.Barcode_NUMB  
          						  AND FO.Recipient_CODE = N1.Recipient_CODE  
          						  AND FO.Notice_ID = N1.Notice_ID  
          							AND EXISTS (SELECT 1  
            									FROM UDMNR_V1 MN  
           										WHERE MN.Case_IDNO = N1.Case_IDNO
             									AND MN.Topic_IDNO = FO.Topic_IDNO))  
							AND ISNUMERIC(N1.Notice_ID) = @Li_Zero_NUMB

							 UNION
       			 SELECT N2.TransactionEventSeq_NUMB,    
                   N2.Generate_DTTM,    
                   N2.Notice_ID,    
                   N2.Recipient_CODE,    
                   @Li_Zero_NUMB,    
                   N2.Recipient_ID,    
                   N2.WorkerRequest_ID,    
                   N2.TypeService_CODE,    
                   @Lc_Empty_Text,    
                   N2.StatusNotice_CODE,    
                   N2.Barcode_NUMB,    
                   COUNT(1) OVER() AS RowCount_NUMB,    
                   ROW_NUMBER() OVER ( ORDER BY N2.Generate_DTTM DESC ) AS Row_NUMB,    
                   N2.LoginWrkOficAttn_ADDR,    
                   N2.LoginWorkersOffice_NAME,    
                   N2.LoginWrkOficLine1_ADDR,    
                   N2.LoginWrkOficLine2_ADDR,    
                   N2.LoginWrkOficCity_ADDR,    
     			   N2.LoginWrkOficState_ADDR,    
                   N2.LoginWrkOficZip_ADDR,    
                   N2.LoginWorkerOfficeCountry_ADDR,    
                   N2.RecipientAttn_ADDR,    
                   N2.Recipient_NAME,    
                   N2.RecipientLine1_ADDR,    
                   N2.RecipientLine2_ADDR,    
                   N2.RecipientCity_ADDR,    
                   N2.RecipientState_ADDR,    
                   N2.RecipientZip_ADDR,    
                   N2.RecipientCountry_ADDR    
                FROM NRRQ_Y1 N2      
                WHERE N2.Generate_DTTM BETWEEN @Ad_From_DATE AND DATEADD (DD, @Li_One_NUMB, @Ad_To_DATE)   
                 AND N2.Notice_ID = ISNULL (@Ac_Notice_ID, N2.Notice_ID)      
                 AND N2.Recipient_ID = ISNULL(@Ac_Recipient_ID, N2.Recipient_ID)    
                 AND N2.Notice_ID = @Lc_Notice_ID_CSI13
				 AND ISNULL(@An_Case_IDNO, @Li_Zero_NUMB) = @Li_Zero_NUMB 
				 AND ISNULL(@Ac_File_ID , @Lc_Empty_Text) = @Lc_Empty_Text
				 AND ISNULL(@Ac_Notice_ID ,@Lc_Notice_ID_CSI13) =@Lc_Notice_ID_CSI13
				 AND ISNUMERIC(N2.Notice_ID) = @Li_Zero_NUMB
          ) H
    ) N   
   WHERE ( @Ai_RowFrom_NUMB = @Li_Zero_NUMB  AND @Ai_RowTo_NUMB = @Li_Zero_NUMB )
      OR ( N.Row_NUMB BETWEEN @Ai_RowFrom_NUMB AND @Ai_RowTo_NUMB )
 END;  -- END OF NRRQ_RETRIEVE_S2  


GO
