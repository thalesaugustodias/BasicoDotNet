using Bernhoeft.GRT.Core.EntityFramework.Domain.Interfaces;
using Bernhoeft.GRT.Core.Helper;
using Bernhoeft.GRT.Teste.Domain.Entities;
using Bernhoeft.GRT.Teste.Infra.Persistence.InMemory.Mappings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace Bernhoeft.GRT.Teste.Infra.Persistence.InMemory.Microsoft.Extensions.DependencyInjection
{
    public static class IServiceCollectionExtensions
    {
        /// <summary>
        /// Adicionar Context de Conexão com Banco de Dados.
        /// </summary>
        public static IServiceCollection AddDbContext(this IServiceCollection @this)
        {
            @this.AddBernhoeftDbContext<AvisoMap>((serviceProvider, options) =>
            {
                options.UseInMemoryDatabase("TesteDb", b => b.EnableNullChecks(false));
            });
            
            @this.RegisterServicesFromAssemblyContaining<AvisoMap>(); // Register Repositories with InjectServiceAttribute.

            // Create DataBase in Memory.
            using var serviceProvider = @this.BuildServiceProvider();
            var dbContext = serviceProvider.GetRequiredService<IContext>();
            
            AsyncHelper.RunSync(async () =>
            {
                await ((DbContext)dbContext).Database.EnsureCreatedAsync();
                
                var avisoDbSet = ((DbContext)dbContext).Set<AvisoEntity>();
                if (!await avisoDbSet.AnyAsync())
                {
                    avisoDbSet.AddRange(
                        new AvisoEntity
                        {
                            Titulo = "Manutenção Programada",
                            Mensagem = "Sistema estará em manutenção no dia 15/12/2024 das 00:00 às 06:00.",
                            Ativo = true,
                            CriadoEm = DateTime.UtcNow.AddDays(-5)
                        },
                        new AvisoEntity
                        {
                            Titulo = "Nova Funcionalidade",
                            Mensagem = "Implementamos melhorias no sistema de avisos com controle de auditoria.",
                            Ativo = true,
                            CriadoEm = DateTime.UtcNow.AddDays(-2),
                            EditadoEm = DateTime.UtcNow.AddDays(-1)
                        },
                        new AvisoEntity
                        {
                            Titulo = "Aviso Desativado",
                            Mensagem = "Este aviso foi desativado e não deve aparecer nas consultas.",
                            Ativo = false,
                            CriadoEm = DateTime.UtcNow.AddDays(-10),
                            EditadoEm = DateTime.UtcNow.AddDays(-8)
                        }
                    );
                    
                    await ((DbContext)dbContext).SaveChangesAsync();
                }
            });

            return @this;
        }
    }
}