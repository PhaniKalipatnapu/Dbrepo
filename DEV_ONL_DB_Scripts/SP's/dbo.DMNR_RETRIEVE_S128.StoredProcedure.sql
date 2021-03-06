/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S128]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMNR_RETRIEVE_S128]
(
   @Ad_Entered_DATE     DATE,
   @An_Case_IDNO        NUMERIC(6, 0),    
   @An_Membermci_IDNO	NUMERIC(10, 0), 
   @An_MajorIntSeq_NUMB		NUMERIC(5,0) OUTPUT,
   @An_MinorIntSeq_NUMB		NUMERIC(5,0) OUTPUT
 )  
As
 /*                                                                                                                                                       
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S128                                                                                                              
  *     DESCRIPTION       : Retrieves major and minor int sequence of the respective cportal alert.  
  *     DEVELOPED BY      : IMP Team                                                                                                                    
  *     DEVELOPED ON      : 16-MAY-2012                                                                                                                   
  *     MODIFIED BY       :                                                                                                                               
  *     MODIFIED ON       :                                                                                                                               
  *     VERSION NO        : 1                                                                                                                             
 */       

    BEGIN  
    
     SET @An_MajorIntSeq_NUMB =NULL;
	 SET @An_MinorIntSeq_NUMB = NULL; 
     
     
    DECLARE
    @Lc_ActivityMajor_CODE  CHAR(4) ='CASE',
    @Lc_ActivityMinor_CODE  CHAR(5) = 'RCWSU',
    @Lc_Status_CODE			CHAR(4) = 'STRT'
     
SELECT TOP 1 @An_MajorIntSeq_NUMB = MajorIntSeq_NUMB,@An_MinorIntSeq_NUMB = MinorIntSeq_NUMB from dmnr_y1 
where Entered_DATE = @Ad_Entered_DATE
AND case_idno = @An_Case_IDNO 
AND MemberMci_IDNO = @An_Membermci_IDNO
and ActivityMajor_CODE = @Lc_ActivityMajor_CODE
AND ActivityMinor_CODE = @Lc_ActivityMinor_CODE
AND Status_CODE = @Lc_Status_CODE;

END



GO
