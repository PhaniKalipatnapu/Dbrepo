/****** Object:  StoredProcedure [dbo].[COPT_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COPT_RETRIEVE_S13] (
 @An_County_IDNO      NUMERIC(3, 0),
 @An_OthpDfltLab_IDNO NUMERIC(9, 0) OUTPUT,
 @As_OtherParty_NAME  VARCHAR(60) OUTPUT
 )
AS
 /*                                                                                                                                              
  *     PROCEDURE NAME    : COPT_RETRIEVE_S13                                                                                                     
  *     DESCRIPTION       : Retrieve the Default lab for the minor activity.        
  *     DEVELOPED BY      : IMP Team                                                                                                           
  *     DEVELOPED ON      : 29-AUG-2011                                                                                                      
  *     MODIFIED BY       :                                                                                                                      
  *     MODIFIED ON       :                                                                                                                      
  *     VERSION NO        : 1                                                                                                                    
 */
 BEGIN
  SELECT @An_OthpDfltLab_IDNO = NULL,
         @As_OtherParty_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_OthpDfltLab_IDNO = CASE
                                 WHEN C.OthpDfltLab_IDNO = 0
                                  THEN -1
                                 ELSE C.OthpDfltLab_IDNO
                                END,
         @As_OtherParty_NAME = (SELECT O.OtherParty_NAME
                                  FROM OTHP_Y1 O
                                 WHERE O.OtherParty_IDNO = C.OthpDfltLab_IDNO
                                   AND O.EndValidity_DATE = @Ld_High_DATE)
    FROM COPT_Y1 C
   WHERE C.County_IDNO = @An_County_IDNO;
 END; -- END OF  COPT_RETRIEVE_S13                                                                                                                                          



GO
