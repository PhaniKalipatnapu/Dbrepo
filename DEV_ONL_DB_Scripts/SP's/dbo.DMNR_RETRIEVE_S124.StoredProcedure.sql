/****** Object:  StoredProcedure [dbo].[DMNR_RETRIEVE_S124]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[DMNR_RETRIEVE_S124]
 (
   @An_Case_IDNO                     NUMERIC(6, 0),  
   @An_Schedule_NUMB                 NUMERIC(10, 0),
   @Ac_ReasonStatus_CODE             CHAR(2)  OUTPUT
 )
As
 
 /*                                                                                                                                                     
  *     PROCEDURE NAME    : DMNR_RETRIEVE_S124                                                                                                            
  *     DESCRIPTION       : Retrieve the Reasonstatus_Code for shown the proceeding type and schedulingUnit_Code in Modify scheduling pop up.  
  *     DEVELOPED BY      : IMP Team                                                                                                                  
  *     DEVELOPED ON      : 16-MAY-2012                                                                                                                 
  *     MODIFIED BY       :                                                                                                                             
  *     MODIFIED ON       :                                                                                                                             
  *     VERSION NO        : 1                                                                                                                           
 */    
 
BEGIN
   
  SET @Ac_ReasonStatus_CODE =NULL;

  SELECT  @Ac_ReasonStatus_CODE=ReasonStatus_CODE 
   FROM DMNR_Y1 D
  WHERE CASE_IDNO=@An_Case_IDNO 
   AND MinorIntSeq_NUMB = (SELECT MAX(MinorIntSeq_NUMB) -1
                             FROM DMNR_Y1 D1
                           WHERE D1.CASE_IDNO= D.CASE_IDNO
                            AND D1.MajorIntSeq_NUMB= D.MajorIntSeq_NUMB
                            AND D1.Schedule_NUMB =@An_Schedule_NUMB) 
                            
                            
 END; -- END OF DMNR_RETRIEVE_S124                                
GO
