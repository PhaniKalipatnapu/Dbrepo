/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S13] (
 @An_Office_IDNO 	 NUMERIC(3),
 @As_Office_NAME     VARCHAR(60) OUTPUT,
 @An_OtherParty_IDNO NUMERIC(9, 0) OUTPUT,
 @An_County_IDNO     NUMERIC(3) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OFIC_RETRIEVE_S13
  *     DESCRIPTION       : Retrieve the County Code for an Office.
  *     DEVELOPED BY      : IMP TEAM
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  SELECT @An_County_IDNO = NULL,
  	     @An_OtherParty_IDNO = NULL,
         @As_Office_NAME = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';
          

  SELECT @An_County_IDNO = O.County_IDNO,
  		 @As_Office_NAME = O.Office_NAME,
         @An_OtherParty_IDNO = O.OtherParty_IDNO
    FROM OFIC_Y1 O
   WHERE O.Office_IDNO = @An_Office_IDNO
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END

GO
