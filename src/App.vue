<script>
import { marked } from 'marked';

export default {
    data() {
        return {
            menuVisible: true,
            styles: ['boogie-woogie', 'lindy-hop', 'lindy-fast'],
            categories: ['passi', 'video'],
            index: [],
            content: '',
            state: {
                style: 0,
                category: 0,
                entry: 0,
            }
        }
    },
    async created() {
        this.onStyleClick(0);
    },
    methods: {
        pseudoMdToHtml(md) {
            const style = this.styles[this.state.style];
            const blocks = md.replaceAll(/\n?img\:(.*)\n?/g, '[block-separator][image-block]$1[block-separator]')
                .replaceAll(/\n?video\:(.*)\n?/g, '[block-separator][video-block]$1[block-separator]')
                .split('[block-separator]').filter(x => x !== '')
            let output = ""
            for (const block of blocks) {
                if (block.startsWith('[image-block]')) {
                    output += `<img src="res/${style}/immagini/${block.substring(13)}" width="100%"/>`
                } else if (block.startsWith('[video-block]')) {
                    output += '<video width="80%" controls>'
                    output += `<source src="res/${style}/video/${block.substring(13)}">`
                    output += '</video>'
                } else {
                    output += marked(block);
                }
            }
            return output
        },
        async onEntryClick(entry) {
            const style = this.styles[this.state.style];
            if (this.state.category === 0) {
                const fileName = this.index[entry].replaceAll(/\s/g, '_') + '.md';
                let res = await fetch(`res/${style}/passi/${fileName}`);
                let data = await res.text();
                this.state.entry = entry;
                this.content = this.pseudoMdToHtml(data);
            } else {
                const fileName = this.index[entry].replaceAll(/\//g, '-') + '.mp4'
                this.state.entry = entry;
                this.content = `<h1>${this.index[entry]}</h1>`
                this.content += '<video width="100%" controls>';
                this.content += `<source src="res/${style}/video/${fileName}">`;
                this.content += '</video>';
            }
        },
        async onStyleClick(tab) {
            this.content = '';
            this.state.entry = 0;
            this.state.category = 0;
            this.state.style = tab;

            this.onCategoryClick(0);
        },
        async onCategoryClick(cat) {
            this.content = '';
            this.state.entry = 0;
            this.state.category = cat;

            const style = this.styles[this.state.style];
            const category = this.state.category == 0 ? 'passi' : 'video';
            let res = await fetch(`res/${style}/${category}/index`);
            let data = await res.text();

            this.index = data.split('\n').filter(x => x != '');

            this.onEntryClick(0);
        }
    },
}
</script>

<template>
    <div class="view">
        <div class="menu">
            <div class="menu-header">
                <span class="material-symbols-outlined" @click="menuVisible = !menuVisible">
                    menu
                </span>
                <div class="title">
                    Enciclopedia Swing v0.2
                </div>
            </div>
            <div class="menu-back" :class="menuVisible ? 'visible' : 'invisible'" @click="menuVisible = !menuVisible" />
            <div class="menu-panel" :class="menuVisible ? 'visible' : 'invisible'">
                <div class=" tabs">
                    <div v-for="(tab, i) in ['Boogie Woogie', 'Lindy Hop', 'Lindy Fast']" class="tab"
                        :class="this.state.style === i ? 'selected' : ''" @click="onStyleClick(i)">
                        {{ tab }}
                    </div>
                </div>
                <div class=" tabs">
                    <div v-for="(tab, i) in ['Passi', 'Video']" class="tab"
                        :class="this.state.category === i ? 'selected' : ''" @click="onCategoryClick(i)">
                        {{ tab }}
                    </div>
                </div>
                <div class="list">
                    <div v-for="(entry, i) in index" @click="onEntryClick(i); menuVisible = false;"
                        :class="this.state.entry == i ? 'selected' : ''">
                        {{ entry }}
                    </div>
                </div>
            </div>
        </div>
        <div class="page" v-html="content">
        </div>
    </div>
</template>

<style lang="scss">
.view {
    min-height: 100%;

    .menu {
        .menu-panel {
            display: flex;
            flex-direction: column;

            .tabs {

                .tab {
                    width: 100%;
                    cursor: pointer;
                    padding: 0.5rem 0;
                    display: flex;
                    justify-content: center;


                    &:hover,
                    &.selected {
                        background-color: #285577;
                    }
                }
            }

            .list {
                overflow-y: scroll;
                display: flex;
                flex-direction: column;
                align-items: center;

                div {
                    padding: 0.5rem 0;
                    width: 100%;
                    text-align: center;
                    cursor: pointer;

                    &:hover,
                    &.selected {
                        background-color: #285577;
                    }
                }
            }
        }
    }

    .page {
        display: flex;
        flex-direction: column;
        align-items: center;

        h1,
        h2,
        h3,
        h4,
        h5 {
            width: 100%;
        }

        h1 {
            text-align: center;
            padding-bottom: 1rem;
        }

        h2 {
            padding-top: 2rem;

            &::before {
                content: "> ";
            }
        }

        h3 {
            padding-top: 1rem;

            &::before {
                content: ">> ";
            }
        }

        h4 {
            padding-top: 1rem;

            &::before {
                content: '>>> '
            }
        }

        h5 {
            padding-top: 1rem;

            &::before {
                content: '>>>> '
            }
        }

        table {
            margin: 1rem 0 2rem 0;
            padding: 0.5rem;
            border: 1px solid white;
            border-radius: 8px;

            gap: 1rem;

            th {
                text-align: center;
            }

            td:first-child {
                display: flex;
                justify-content: center;
            }

            td {
                padding: 0.5rem 0;
            }
        }

    }
}

@media (min-width: 501px) {
    .view {
        width: 80rem;
        padding: 1rem;
        display: grid;
        grid-template-columns: 1fr 3fr;

        .menu {
            border: 2px white solid;
            border-top-left-radius: 10px;
            border-bottom-left-radius: 10px;

            .menu-header {
                display: none;
            }

            .menu-back {
                display: none;
            }

            .menu-panel {
                padding: 1rem;

                display: flex;
                flex-direction: column;
                gap: 2rem;
            }
        }

        .page {
            padding: 2rem 2rem;
            border: 2px white solid;
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
            border-left: none;
        }
    }
}

@media (max-width: 500px) {
    .view {
        position: relative;
        width: 100%;
        max-height: 100vh;
        display: flex;
        flex-direction: column;

        .menu {

            .menu-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px white solid;

                .material-symbols-outlined {
                    font-size: 2rem;
                    padding: 0.5rem 1rem;
                }

                .title {
                    padding: 0.5rem 1rem;
                    font-weight: bold;
                }

            }

            .menu-back {
                background-color: #000000aa;
                position: absolute;
                top: 0;
                right: 0;
                bottom: 0;
                left: 0;

                display: none;

                &.visible {
                    display: block;
                }
            }

            .menu-panel {
                padding: 1rem;
                position: absolute;
                left: 0;
                top: 0;
                background-color: #282C33;
                min-height: 100vh;
                max-height: 100vh;
                width: 50%;

                display: flex;
                flex-direction: column;
                gap: 2rem;

                transition: all 0.5s;
                transform: translateX(-100%);

                &.visible {
                    transform: translateX(0);
                }
            }
        }

        .page {
            max-height: 100%;
            padding: 1rem 0.5rem;
            overflow-y: scroll;
        }
    }
}
</style>
