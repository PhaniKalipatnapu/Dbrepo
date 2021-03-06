/****** Object:  StoredProcedure [dbo].[CASE_RETRIEVE_S137]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CASE_RETRIEVE_S137] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Worker_ID   CHAR(30) OUTPUT,
 @An_County_IDNO NUMERIC(3, 0) OUTPUT,
 @An_Office_IDNO NUMERIC(3, 0) OUTPUT,
 @Ac_First_NAME  CHAR(16) OUTPUT,
 @Ac_Middle_NAME CHAR(20) OUTPUT,
 @Ac_Last_NAME   CHAR(20) OUTPUT,
 @Ac_Suffix_NAME CHAR(4) OUTPUT
 )
AS
 /*                                                                                                                                  
  *     PROCEDURE NAME    : CASE_RETRIEVE_S137                                                                                        
  *     DESCRIPTION       : Retrieve County and Office in which the Case is Created for a Case Idno. 
  *     DEVELOPED BY      : IMP Team                                                                                               
  *     DEVELOPED ON      : 24-AUG-2011                                                                                           
  *     MODIFIED BY       :                                                                                                          
  *     MODIFIED ON       :                                                                                                          
  *     VERSION NO        : 1                                                                                                        
 */
 BEGIN
  SELECT @An_County_IDNO = NULL,
         @An_Office_IDNO = NULL,
         @Ac_Worker_ID = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_County_IDNO = C.County_IDNO,
         @An_Office_IDNO = C.Office_IDNO,
         @Ac_Worker_ID = C.Worker_ID,
         @Ac_Last_NAME = U.Last_NAME,
         @Ac_Suffix_NAME = U.Suffix_NAME,
         @Ac_First_NAME = U.First_NAME,
         @Ac_Middle_NAME = U.Middle_NAME
    FROM CASE_Y1 C
         JOIN USEM_Y1 U
          ON U.Worker_ID = C.Worker_ID
   WHERE U.EndValidity_DATE = @Ld_High_DATE
     AND C.Case_IDNO = @An_Case_IDNO;
 END; --END OF CASE_RETRIEVE_S137                                                                                                                          


GO
