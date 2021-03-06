/****** Object:  StoredProcedure [dbo].[ANXT_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ANXT_RETRIEVE_S4] (
 @Ac_ActivityMajor_CODE CHAR(4),
 @An_ActivityOrder_QNTY NUMERIC(3, 0) OUTPUT
 )
AS
 /*
 *      PROCEDURE NAME    : ANXT_RETRIEVE_S4
  *     DESCRIPTION       : Fetch the sequence of order of Minor Activities within the Remedy for the given code which represents the Major Activity when End Validity date is equal to High date.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 09-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_ActivityOrder_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @An_ActivityOrder_QNTY = MAX (a.ActivityOrder_QNTY)
    FROM ANXT_Y1 a
   WHERE a.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of ANXT_RETRIEVE_S4

GO
