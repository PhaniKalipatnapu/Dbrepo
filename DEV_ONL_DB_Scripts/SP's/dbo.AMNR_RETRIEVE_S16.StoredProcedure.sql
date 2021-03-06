/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S16]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S16] 

 
AS
 /*                                                                                                                                                             
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S16                                                                                                                    
  *     DESCRIPTION       : Retrieve the Minor Activity Code and Description where Minor Activity Code is equal to CP/NCP Appointment or Unscheduled Proceeding.
  *     DEVELOPED BY      : IMP Team                                                                                                                          
  *     DEVELOPED ON      : 19-AUG-2011                                                                                                                      
  *     MODIFIED BY       :                                                                                                                                     
  *     MODIFIED ON       :                                                                                                                                     
  *     VERSION NO        : 1                                                                                                                                   
 */
 BEGIN
  DECLARE @Ld_High_DATE               DATE = '12/31/9999',
          @Lc_Element_ID              CHAR(1) ='S';
 

  SELECT A.ActivityMinor_CODE,
         A.DescriptionActivity_TEXT
    FROM AMNR_Y1 A
   WHERE A.Element_ID = @Lc_Element_ID
     AND A.EndValidity_DATE = @Ld_High_DATE
   ORDER BY A.DescriptionActivity_TEXT;
 END; --END OF AMNR_RETRIEVE_S16                                                                                                                                                            ;


GO
