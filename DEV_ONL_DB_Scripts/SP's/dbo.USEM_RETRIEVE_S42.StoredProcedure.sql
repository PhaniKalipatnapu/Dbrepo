/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S42]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S42] (
 @An_Office_IDNO NUMERIC(3, 0),
 @Ac_Last_NAME   CHAR(20)
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S42
  *     DESCRIPTION       : Retrive office worker in Last name order
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/26/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT a.Worker_ID,
         a.First_NAME,
         a.Middle_NAME,
         a.Last_NAME,
         a.Suffix_NAME
    FROM USEM_Y1 a
         JOIN UASM_Y1 b
          ON b.Worker_ID = a.Worker_ID
   WHERE b.Office_IDNO = @An_Office_IDNO
     AND a.Last_NAME = ISNULL(@Ac_Last_NAME,a.Last_NAME)
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
   ORDER BY a.Last_NAME;
 END


GO
