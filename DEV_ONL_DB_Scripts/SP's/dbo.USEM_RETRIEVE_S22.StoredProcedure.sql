/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S22]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S22]
AS
 /*
 *      PROCEDURE NAME    : USEM_RETRIEVE_S22
  *     DESCRIPTION       : Retrireve the Worker Details.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT U.Worker_ID,
         U.First_NAME,
         U.Middle_NAME,
         U.Last_NAME,
         U.Suffix_NAME
    FROM USEM_Y1 U
   WHERE U.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of USEM_RETRIEVE_S22

GO
