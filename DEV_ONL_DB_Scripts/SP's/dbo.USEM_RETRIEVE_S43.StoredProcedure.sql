/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S43]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S43] (
 @Ac_Last_NAME CHAR(20)
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S43
  *     DESCRIPTION       : Retrieve Last Name, First, Middle Name of the Worker and Unique Worker ID for a Last Name 
 							of the Worker when end validity date is equal to high date; sort by First Name of the worker.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/26/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT U.Worker_ID,
         U.First_NAME,
         U.Middle_NAME,
         U.Last_NAME,
         U.Suffix_NAME
    FROM USEM_Y1 U
   WHERE U.Last_NAME = @Ac_Last_NAME
     AND U.EndValidity_DATE = @Ld_High_DATE
   ORDER BY First_NAME;
 END


GO
